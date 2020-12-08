defmodule BattleCity.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      BattleCity.Process.StageCache,
      BattleCity.Process.ProcessRegistry,
      BattleCity.Process.GameDynamicSupervisor,
      # Start the Ecto repository
      BattleCity.Repo,
      # BattleCity.Process.RandomWord,
      # Start the Telemetry supervisor
      BattleCityWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BattleCity.PubSub},
      BattleCityWeb.Presence,
      # Start the Endpoint (http/https)
      BattleCityWeb.Endpoint,
      # Start a worker by calling: BattleCity.Worker.start_link(arg)
      # {BattleCity.Worker, arg}
      {BattleCity.Process.TelemetryStorage, BattleCityWeb.Telemetry.metrics()}
    ]

    :ok = BattleCity.Telemetry.attach_default_logger(:debug)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BattleCity.Supervisor]
    result = Supervisor.start_link(children, opts)
    _ = if Mix.env() != :test, do: BattleCity.Game.mock()
    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BattleCityWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
