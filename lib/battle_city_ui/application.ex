defmodule BattleCityUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      BattleCityUi.Repo,
      BattleCityUiWeb.Telemetry,
      {Phoenix.PubSub, name: BattleCityUi.PubSub},
      BattleCityUiWeb.Presence,
      BattleCityUiWeb.Endpoint,
      {BattleCityUi.TelemetryStorage, BattleCityUiWeb.Telemetry.metrics()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BattleCityUi.Supervisor]
    result = Supervisor.start_link(children, opts)
    # _ = if Mix.env() == :dev, do: BattleCity.Game.mock()
    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BattleCityUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
