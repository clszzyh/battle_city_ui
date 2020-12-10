defmodule BattleCity.Environment.BrickWall do
  @moduledoc false

  use BattleCity.Environment,
    enter?: false,
    health: :infinite,
    color: "#FC5C94"
end
