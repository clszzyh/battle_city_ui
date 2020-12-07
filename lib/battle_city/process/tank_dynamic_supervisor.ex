defmodule BattleCity.Process.TankDynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor
  use BattleCity.Process.ProcessRegistry
  # alias BattleCity.Context
  alias BattleCity.Process.GameServer
  alias BattleCity.Process.TankServer

  def start_link({slug, args}) do
    {:ok, srv} = DynamicSupervisor.start_link(__MODULE__, {slug, args}, name: via_tuple(slug))

    slug
    |> GameServer.pid()
    |> GameServer.ctx()
    |> Map.fetch!(:tanks)
    |> Map.keys()
    |> Enum.each(fn id ->
      server_process(srv, id)
    end)

    {:ok, srv}
  end

  @impl true
  def init({slug, _args}) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [slug])
  end

  def start_tank_process(slug, id) do
    srv = pid(slug)
    server_process(srv, id)
  end

  def server_process(srv, args) do
    case start_child(srv, args) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(srv, args) do
    DynamicSupervisor.start_child(srv, {TankServer, args})
  end

  def children(srv) do
    childs = DynamicSupervisor.which_children(srv)
    for {_, pid, :worker, [module]} <- childs, do: %{pid: pid, module: module}
  end
end
