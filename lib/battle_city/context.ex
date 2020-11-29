defmodule BattleCity.Context do
  @moduledoc false

  defstruct [
    :score,
    :lives,
    :rest_enemies,
    :stage,
    :players,
    :enemies,
    shovel?: false
  ]

  # alias BattleCity.Tank

  # def handle_all_enemies(%__MODULE__{} = ctx, %Tank{} = tank) do
  # end
end
