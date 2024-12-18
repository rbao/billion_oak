defmodule BillionOak.MixProject do
  use Mix.Project

  def project do
    [
      app: :billion_oak,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BillionOak.Application, []},
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
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:xcuid, "~> 0.1.1"},
      {:ex_aws, "~> 2.5.6"},
      {:ex_aws_s3, "~> 2.5.4"},
      # aws uses hackney
      {:hackney, "~> 1.20.1"},
      # required for s3 list_objects_v2
      {:sweet_xml, "~> 0.7.4"},
      {:csv, "~> 3.2"},
      {:timex, "~> 3.7.11"},
      {:ok, "~> 2.2.0"},
      {:absinthe, "~> 1.7.8"},
      {:absinthe_phoenix, "~> 2.0.3"},
      {:joken, "~> 2.6.2"},
      {:typedstruct, "~> 0.5.3"},
      {:req, "~> 0.5.6"},
      {:dataloader, "~> 2.0.1"},
      {:mox, "~> 1.2.0", only: :test},
      {:ex_machina, "~> 2.8.0", only: :test},
      {:faker, "~> 0.18.0", only: :test}
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
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
