defmodule BattleCity.Process.TankServer do
  @moduledoc false

  use GenServer
  use BattleCity.Process.ProcessRegistry

  def start_link(slug, id) do
    GenServer.start_link(__MODULE__, {slug, id}, name: via_tuple({slug, id}))
  end

  @impl true
  def init(args) do
    {:ok, args}
  end
end
