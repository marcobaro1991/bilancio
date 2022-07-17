defmodule Bilancio.MixProject do
  use Mix.Project

  def project do
    [
      app: :bilancio,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:ex_unit],
        plt_add_deps: :transitive,
        ignore_warnings: ".dialyzerignore"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Bilancio.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:amqpx, "~> 5.7"},
      {:absinthe, "~> 1.6.0"},
      {:absinthe_plug, "~> 1.5"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:cors_plug, "~> 3.0"},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dataloader, "~> 1.0.0"},
      {:phoenix, "~> 1.6.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.6"},
      {:noether, "~> 0.2.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:prima_ex_logger, "~> 0.2.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:parallel_task, "~> 0.1.1"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:uuid, "~> 1.1", app: false},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:timex, "~> 3.7"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:joken, "~> 2.5"},
      {:redix, "~> 1.1"},
      {:plug_cowboy, "~> 2.5"}
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
      check: [
        "check.compile",
        "check.format",
        "check.deps.unlock",
        "check.credo",
        "check.dialyzer"
      ],
      "format.all": [
        "format mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\" \"priv/**/*.{ex,exs}\" \"config/**/*.{ex,exs}\""
      ],
      "ecto.clear": ["ecto.drop", "ecto.create", "ecto.migrate"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      s: ["local.hex --force", "phx.server"],
      sdl: fn _ -> sdl_command(Bilancio.Graphql.Schema, "generate") end,
      "sdl.verify": fn _ -> sdl_command(Bilancio.Graphql.Schema, "verify") end,
      c: ["check"],
      "check.compile":
        "compile --all-warnings --ignore-module-conflict --warnings-as-errors --debug-info",
      "check.format":
        "format --check-formatted mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\" \"priv/**/*.{ex,exs}\" \"config/**/*.{ex,exs}\"",
      "check.deps.unlock": "deps.unlock --check-unused",
      "check.credo": "credo -a --strict",
      "check.dialyzer": "dialyzer --format dialyxir",
      test: ["local.hex --force", "ecto.reset", "test"],
      "test.coverage": ["test --cover --export-coverage default", "test.coverage"]
    ]
  end

  defp sdl_command(schema, command) do
    with 0 <- Mix.shell().cmd("catalog/graphql-schema.sh #{command} #{schema} api") do
      :ok
    else
      _ -> raise "fail to #{command} #{schema} schema"
    end
  end
end
