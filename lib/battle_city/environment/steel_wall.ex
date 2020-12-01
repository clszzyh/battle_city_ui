defmodule BattleCity.Environment.SteelWall do
  @moduledoc false

  use BattleCity.Environment,
    health: 4,
    enter?: false

  @shape_map %{
    "f" => 1,
    "3" => 2,
    "c" => 3,
    "5" => 4,
    "a" => 5
  }

  @shapes Map.keys(@shape_map)

  @impl true
  def handle_init(%{shape: shape}) when shape in @shapes do
    %{shape: shape, health: @shape_map[shape]}
  end

  def handle_init(_), do: {:error, :not_found}
end
