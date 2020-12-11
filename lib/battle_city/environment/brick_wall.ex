defmodule BattleCity.Environment.BrickWall do
  @moduledoc false

  use BattleCity.Environment,
    enter?: false,
    health: :infinite,
    color: "#BB1300"
end
