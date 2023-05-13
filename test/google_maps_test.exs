defmodule GoogleMapsTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  setup do
    bypass = Bypass.open()
    endpoint = "http://localhost:#{bypass.port}/maps/api/place/details/json"
    {:ok, bypass: bypass, endpoint: endpoint}
  end

  test "ensure an error is returned if the params list is invalid", %{endpoint: endpoint} do
    {result, log} =
      with_log(fn ->
        GoogleMaps.call(endpoint, key: [:invalid, :list])
      end)

    assert {:error, _} = result
    assert log =~ "Invalid URL"
  end

  test "ensure an error is returned if the server is down", %{
    bypass: bypass,
    endpoint: endpoint
  } do
    Bypass.down(bypass)

    {result, log} =
      with_log(fn ->
        GoogleMaps.call(endpoint)
      end)

    assert {:error, _} = result
    assert log =~ "econnrefused"
  end

  test "ensure an error is returned if the endpoint does not exist", %{
    bypass: bypass,
    endpoint: endpoint
  } do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 404, "")
    end)

    {result, log} =
      with_log(fn ->
        GoogleMaps.call(endpoint <> "/invalid-url")
      end)

    assert {:error, _} = result
    assert log =~ "404"
  end

  test "ensure an error is returned if the server response is not json", %{
    bypass: bypass,
    endpoint: endpoint
  } do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, "text")
    end)

    {result, log} =
      with_log(fn ->
        GoogleMaps.call(endpoint)
      end)

    assert {:error, _} = result
    assert log =~ "Invalid JSON"
  end

  test "ensure an error is returned if a place_id was not found", %{
    bypass: bypass,
    endpoint: endpoint
  } do
    Bypass.expect(bypass, fn conn ->
      json = Jason.encode!(%{status: "NOT_FOUND", result: %{}})
      Plug.Conn.resp(conn, 200, json)
    end)

    {result, log} =
      with_log(fn ->
        GoogleMaps.call(endpoint)
      end)

    assert {:not_found, _} = result
    assert log =~ "The id was not found"
  end

  test "ensure the server response is valid json", %{bypass: bypass, endpoint: endpoint} do
    Bypass.expect(bypass, fn conn ->
      json = Jason.encode!(%{status: "OK", result: %{}})
      Plug.Conn.resp(conn, 200, json)
    end)

    assert {:ok, %{}} = GoogleMaps.call(endpoint)
  end

  test "ensure the server does not return results", %{bypass: bypass, endpoint: endpoint} do
    Bypass.expect(bypass, fn conn ->
      json = Jason.encode!(%{status: "ZERO_RESULTS", results: %{}})
      Plug.Conn.resp(conn, 200, json)
    end)

    assert {:ok, _} = GoogleMaps.call(endpoint)
  end
end
