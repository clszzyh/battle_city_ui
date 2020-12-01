defmodule BattleCity.Environment.SteelWall do
  @moduledoc false

  use BattleCity.Environment,
    health: 4,
    enter?: false

  @health_map %{
    "f" => 1,
    "3" => 2,
    "c" => 3,
    "5" => 4,
    "a" => 5
  }

  @stages Map.keys(@health_map)

  @impl true
  def handle_init(%{stage: stage}) when stage in @stages do
    %{stage: stage, health: @health_map[stage]}
  end

  def handle_init(map), do: raise(CompileError, description: "Error #{inspect(map)}")
end
