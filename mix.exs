defmodule Grabakey.MixProject do
  use Mix.Project

  def project do
    [
      app: :grabakey,
      version: "0.1.0",
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gun, "~> 2.0"},
      {:cowboy, "~> 2.10"},
      {:ecto_ulid_next, "~> 1.0"},
      {:ecto_sqlite3, "~> 0.10.3"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
