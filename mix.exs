defmodule Pavlov.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [app: :pavlov,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     elixirc_paths: paths(Mix.env),

     # Hex
     description: description,
     package: package,

     # Docs
     name: "Pavlov",
     docs: [source_ref: "v#{@version}",
            source_url: "https://github.com/sproutapp/pavlov"]]
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
      {:meck, "~> 0.8.2"},
      {:ex_doc, "~> 0.6", only: :docs},
      {:earmark, "~> 0.1", only: :docs},
      {:inch_ex, only: :docs}
    ]
  end

  defp description do
    """
    Pavlov is a BDD library for your Elixir projects, allowing you to write
    expressive unit tests that tell the story of how your application behaves.
    The syntax tries to follow RSpec's wherever possible.
    """
  end

  defp package do
    [contributors: ["Bruno Abrantes"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/sproutapp/pavlov"}]
  end

  defp paths(:test), do: ["lib", "test/fixtures"]
  defp paths(_), do: ["lib"]
end
