defmodule BattleCity.Environment.Blank do
  @moduledoc false

  use BattleCity.Environment,
    enter?: true,
    health: 0,
    color: "#000000"
end
