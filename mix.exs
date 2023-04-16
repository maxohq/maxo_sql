defmodule MaxoSql.MixProject do
  use Mix.Project
  @github_url "https://github.com/maxohq/maxo_sql"
  @version "0.1.0"
  @description "MaxoSql is a lean and universal query builder for Elixir (fork from SqlDust)"

  def project do
    [
      app: :maxo_sql,
      source_url: @github_url,
      version: @version,
      description: @description,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: ["test", "lib"],
      test_pattern: "*_test.exs",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MaxoSql.Application, []}
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ~w(lib mix.exs README* CHANGELOG*),
      licenses: ["MIT"],
      links: %{
        "Github" => @github_url,
        "Changelog" => "#{@github_url}/blob/main/CHANGELOG.md"
      }
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:postgrex, :myxql, :exqlite],
      # flags: [:unmatched_returns, :error_handling, :no_opaque]
      flags: [:error_handling, :no_opaque]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:maxo_adapt, "~> 0.1"},
      {:jason, "~> 1.4"},
      {:inflex, "~> 2.1"},

      # DB drivers
      {:postgrex, "~> 0.17", optional: true},
      {:myxql, "~> 0.6.3", optional: true},
      {:exqlite, "~> 0.13", optional: true},
      {:ecto, "~> 3.7", optional: true},

      # Dev tools

      # used in tests, might be generally useful
      {:wait_for_it, "~> 1.1", only: [:test, :dev]},
      {:dialyxir, "~> 1.3", only: :dev, runtime: false},
      {:benchee, "~> 1.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:maxo_test_iex, "~> 0.1.2", only: [:test]},
      {:mneme, "~> 0.3.1", only: [:test]}
    ]
  end
end
