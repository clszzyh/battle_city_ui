defmodule BattleCity.Environment.Blank do
  @moduledoc false

  use BattleCity.Environment,
    allow_pass_tank: true,
    allow_pass_bullet: true,
    allow_destroy: false
end
