defmodule BattleCity.Process.GameSupervisor do
  @moduledoc false

  alias BattleCity.Process.GameServer

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def server_process(name) do
    case start_child(name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(name) do
    DynamicSupervisor.start_child(__MODULE__, {GameServer, name})
  end
end
