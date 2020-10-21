defmodule Schemata.MixProject do
  use Mix.Project

  def project do
    [
      app: :schemata,
      version: "0.1.0",
      elixir: "~> 1.8",
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:json_xema, "~> 0.3.3", optional: true},
      {:nex_json_schema, "~> 0.8.4"}
    ]
  end
end
