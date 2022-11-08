# GoogleMaps

A library to make requests to the Google Maps API.

Check the Google Maps API server address used to send request stored in the
`:google_maps_api_server` key in the `mix.exs` file of the application.

For more information about the endpoints and parameters used in the Google Maps
API, visit the [Google Maps API documentation](https://developers.google.com/maps/documentation).

## Installation

The package can be installed by adding `google_maps` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:google_maps, git: "https://github.com/salva-ruiz/elixir_google_maps.git", tag: "1.0"}
  ]
end
```

## Requirements

In order to use the Google Maps API, first you need to [create an api key](https://developers.google.com/maps/documentation/javascript/get-api-key).

## Usage

Call the `GoogleMaps.call/2` function with the JSON endpoint and the query
params to returns a map with the Google Maps response:

```elixir
GoogleMaps.call("/maps/api/place/textsearch/json", [
  key: "***",
  query: "marbella",
  language: "es",
  region: "es",
  type: "restaurant"
])
```

Returns an error if the endpoint or some param is not valid:

```elixir
GoogleMaps.fetch("/invalid", key: "***", place_id: "xxx")
{:error, "Error description"}
```
