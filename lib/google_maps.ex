defmodule GoogleMaps do
  require Logger

  @moduledoc """
  A module to make requests to the Google Maps API.

  For more information about the endpoints and parameters use for the Google Maps API, visit the
  [Google Maps API documentation](https://developers.google.com/maps/documentation)
  """

  @doc """
  Send a request to the Google Maps API and process the response.

  ## Parameters

    * `endpoint` - the RESTfull part of the API URL to make the request

    * `params` - a map containing the parameters that will be used to build the query string

  ## Examples

      # Returns a valid Place
      params = [key: "???", query: "marbella", language: "es", region: "es", type: "restaurant"]
      GoogleMaps.call("https://maps.googleapis.com/maps/api/place/textsearch/json", params)

      # Returns an error if the `place_id` is not valid
      GoogleMaps.call("/invalid", key: "***", place_id: "xxx")
      {:error, "Error description"}

  """
  @spec call(endpoint, params) ::
          {:ok, map()} | {:ok, [map()]} | {:ok, []} | {:not_found, map()} | {:error, String.t()}
        when endpoint: nonempty_binary(), params: list()
  def call(endpoint, params \\ []) when is_binary(endpoint) and is_list(params) do
    with {:ok, url} <- build_url(endpoint, params),
         {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, response} <- Jason.decode(body, keys: :atoms) do
      case response do
        %{status: "OK", result: result} ->
          {:ok, result}

        %{status: "OK", results: results} ->
          {:ok, results}

        %{status: "ZERO_RESULTS", results: results} ->
          {:ok, results}

        %{status: status, result: result} when status in ~w(ZERO_RESULTS NOT_FOUND) ->
          Logger.warning("The id was not found: #{inspect(result)}")
          {:not_found, result}

        %{status: _status} = response ->
          Logger.error("Invalid request: #{inspect(response)}")
          {:error, response}
      end
    else
      {:ok, %HTTPoison.Response{request: request, request_url: url, status_code: status_code}} ->
        Logger.error("The request #{inspect(request)} in #{url} returned #{status_code}")
        {:error, status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(inspect(reason))
        {:error, reason}

      {:error, %Jason.DecodeError{} = decode_error} ->
        Logger.error("Invalid JSON: #{inspect(decode_error)}")
        {:error, "Invalid JSON"}

      {:error, reason} when is_binary(reason) ->
        Logger.error("Invalid URL: #{reason}")
        {:error, reason}
    end
  end

  defp build_url(endpoint, params) do
    try do
      endpoint
      |> URI.new!()
      |> URI.append_query(URI.encode_query(params))
      |> URI.to_string()
    rescue
      error in URI.Error ->
        {:error, error.reason}

      error in ArgumentError ->
        {:error, error.message}
    else
      url ->
        {:ok, url}
    end
  end
end
