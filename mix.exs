defmodule Pavlov.Mixfile do
  use Mix.Project

  def project do
    [app: :pavlov,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps,
     elixirc_paths: paths(Mix.env)]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:meck, "~> 0.8.2"}
    ]
  end

  defp paths(:test), do: ["lib", "test/fixtures"]
  defp paths(_), do: ["lib"]
end
