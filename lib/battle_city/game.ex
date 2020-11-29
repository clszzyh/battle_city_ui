defmodule BattleCity.Game do
  @moduledoc false

  defstruct [
    :score,
    :lives,
    :rest_enemies,
    :stage,
    :players,
    :enemies
  ]
end
