defmodule BattleCity.Environment.BrickWall do
  @moduledoc false

  use BattleCity.Environment,
    allow_pass_tank: false,
    allow_pass_bullet: false,
    allow_destroy: true
end
