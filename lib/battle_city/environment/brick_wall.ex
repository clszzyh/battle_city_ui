defmodule BattleCity.Environment.BrickWall do
  @moduledoc false

  use BattleCity.Environment,
    allow_pass_tank: false,
    health: :infinite
end
