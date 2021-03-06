defmodule Overdiscord.Mixfile do
  use Mix.Project

  def project do
    [
      app: :overdiscord,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers() ++ [:protocol_ex],
      deps: deps(),
      dialyzer: [
        plt_add_deps: :transitive
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      mod: {Overdiscord, []},
      extra_applications: [
        :logger
      ]
    ]
  end

  defp deps do
    [
      {:inch_ex, "~> 0.5", only: [:docs, :dev, :test]},
      {:credo, "~> 0.8", only: [:docs, :dev, :test]},
      {:alchemy, "~> 0.6.1", hex: :discord_alchemy},
      {:httpoison, "~> 0.12.0", override: true},
      {:exirc, "~> 1.0"},
      {:sizeable, "~> 1.0"},
      # {:meeseeks, "~> 0.7.7"},
      {:meeseeks, github: "mischov/meeseeks"},
      {:opengraph, "~> 0.1.0"},
      {:cachex, "~> 2.1"},
      {:exsync, "~> 0.2", only: :dev},
      {:dialyxir, "~> 0.5.1", only: [:dev, :test], runtime: false},
      {:exleveldb, "~> 0.12"},
      {:gen_stage, "~> 0.13", override: true},
      {:quantum, "~> 2.2"},
      {:timex, "~> 3.1"},
      {:luerl, "~> 0.3"},
      {:protocol_ex, "~> 0.3.12"}
    ]
  end
end
