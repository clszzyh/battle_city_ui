defmodule BattleCity.Process.GameSupervisor do
  @moduledoc false

  use Supervisor
  use BattleCity.Process.ProcessRegistry

  alias BattleCity.Process.GameServer
  alias BattleCity.Process.TankDynamicSupervisor
  # alias BattleCity.Process.TankServer

  def start_link({slug, opts}) do
    Supervisor.start_link(__MODULE__, {slug, opts}, name: via_tuple(slug))
  end

  @impl true
  def init(args) do
    children = [
      {TankDynamicSupervisor, args},
      {GameServer, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_tank(slug, id) do
    slug
    |> TankDynamicSupervisor.pid()
    |> case do
      nil -> {:error, slug}
      srv -> {:ok, TankDynamicSupervisor.server_process(srv, id)}
    end
  end

  def stop_tank(slug, id) do
    slug
    |> TankDynamicSupervisor.pid()
    |> case do
      nil -> {:error, "Not found #{slug}"}
      srv -> TankDynamicSupervisor.terminate_child(srv, {slug, id})
    end
  end
end
