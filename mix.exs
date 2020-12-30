defmodule BattleCityUi.MixProject do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))
  @github_url "https://github.com/clszzyh/battle_city_ui"
  @description String.trim(Enum.at(String.split(File.read!("README.md"), "<!-- MDOC -->"), 1, ""))

  def project do
    [
      app: :battle_city_ui,
      version: @version,
      description: @description,
      elixirc_options: [warnings_as_errors: System.get_env("CI") == "true"],
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: [
        licenses: ["MIT"],
        files: ["lib", ".formatter.exs", "mix.exs", "README*", "CHANGELOG*", "VERSION"],
        exclude_patterns: ["priv/plts", ".DS_Store"],
        links: %{
          "GitHub" => @github_url,
          "Changelog" => @github_url <> "/blob/master/CHANGELOG.md"
        }
      ],
      docs: [
        source_ref: "v" <> @version,
        source_url: @github_url,
        main: "readme",
        extras: ["README.md", "CHANGELOG.md"]
      ],
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
      xref: [exclude: :crypto],
      releases: releases(),
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp releases do
    [
      battle_city_ui: [
        include_executables_for: [:unix],
        steps: [:assemble, &copy_extra_files/1],
        applications: [runtime_tools: :permanent]
      ]
    ]
  end

  defp copy_extra_files(release) do
    File.cp!(".iex.exs", Path.join(release.path, ".iex.exs"))
    release
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
      mod: {BattleCityUi.Application, []},
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
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, github: "clszzyh/phoenix_live_dashboard"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:battle_city, github: "clszzyh/battle_city"},
      # {:battle_city, path: "../battle_city"},
      {:ecto_psql_extras, "~> 0.2"},
      {:circular_buffer, "~> 0.3.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      d: "dialyzer",
      logs: "cmd gigalixir logs",
      ci: [
        "compile --warnings-as-errors --force --verbose",
        "format --check-formatted",
        "credo --strict",
        "docs -f html",
        "dialyzer",
        "test"
      ]
    ]
  end
end
