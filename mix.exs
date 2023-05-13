defmodule GoogleMaps.MixProject do
  use Mix.Project

  def project do
    [
      app: :google_maps,
      version: "2.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:httpoison, "~> 1.8.2"},
      {:bypass, "~> 2.1", only: :test}
    ]
  end
end
