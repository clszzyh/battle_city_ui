defmodule BattleCity.MixProject do
  use Mix.Project

  @version "VERSION" |> File.read!() |> String.trim()
  @github_url "https://github.com/clszzyh/battle_city"
  @description "README.md"
               |> File.read!()
               |> String.split("<!-- MDOC -->")
               |> Enum.fetch!(1)
               |> String.trim()

  def project do
    [
      app: :battle_city,
      version: @version,
      description: @description,
      elixirc_options: [warnings_as_errors: System.get_env("CI") == "true"],
      package: [
        licenses: ["MIT"],
        files: ["lib", ".formatter.exs", "mix.exs", "README*", "CHANGELOG*", "VERSION"],
        exclude_patterns: ["priv/plts", ".DS_Store"],
        links: %{
          "GitHub" => @github_url,
          "Changelog" => @github_url <> "/blob/master/CHANGELOG.md"
        }
      ],
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [ci: :test, dialyzer: :test, d: :test],
      dialyzer: [
        plt_core_path: "priv/plts",
        plt_add_deps: :transitive,
        plt_add_apps: [:ex_unit],
        list_unused_filters: true,
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: dialyzer_flags()
      ],
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp dialyzer_flags do
    [
      :error_handling,
      :race_conditions,
      # :underspecs,
      :unknown,
      :unmatched_returns
      # :overspecs
      # :specdiffs
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BattleCity.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :mix]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.7"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.15.0"},
      {:phoenix_live_session, "~> 0.1"},
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, github: "clszzyh/phoenix_live_dashboard"},
      # {:phoenix_live_dashboard, "~> 0.4"},
      # {:phoenix_live_dashboard, path: "../phoenix_live_dashboard"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ecto_psql_extras, "~> 0.2"},
      {:circular_buffer, "~> 0.3.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      d: "dialyzer",
      ci: [
        "compile --warnings-as-errors --force --verbose",
        "format --check-formatted",
        "credo --strict",
        "dialyzer",
        "test"
      ]
    ]
  end
end
