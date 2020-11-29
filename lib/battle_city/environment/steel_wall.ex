defmodule BattleCity.Environment.SteelWall do
  @moduledoc false

  use BattleCity.Environment,
    allow_pass_bullet: false,
    allow_pass_tank: false,
    allow_destroy: false
end
