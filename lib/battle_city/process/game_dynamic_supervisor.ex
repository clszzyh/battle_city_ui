defmodule BattleCity.Process.GameDynamicSupervisor do
  @moduledoc false

  alias BattleCity.Process.GameSupervisor

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec server_process(BattleCity.slug(), map()) :: pid()
  def server_process(slug, opts \\ %{}) do
    case start_child(slug, opts) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(slug, opts) do
    DynamicSupervisor.start_child(__MODULE__, {GameSupervisor, {slug, opts}})
  end

  def children do
    childs = DynamicSupervisor.which_children(__MODULE__)
    for {_, pid, kind, [module]} <- childs, do: %{pid: pid, kind: kind, module: module}
  end
end
