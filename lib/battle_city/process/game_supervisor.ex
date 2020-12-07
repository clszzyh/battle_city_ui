defmodule BattleCity.Process.GameSupervisor do
  @moduledoc false

  use Supervisor
  use BattleCity.Process.ProcessRegistry

  def start_link({slug, opts}) do
    Supervisor.start_link(__MODULE__, {slug, opts}, name: via_tuple(slug))
  end

  @impl true
  def init(args) do
    children = [
      {BattleCity.Process.GameServer, args},
      {BattleCity.Process.TankDynamicSupervisor, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
