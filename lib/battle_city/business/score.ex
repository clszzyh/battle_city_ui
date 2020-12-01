defmodule BattleCity.Business.Score do
  @moduledoc false

  alias BattleCity.Tank

  @type reason :: atom()

  @spec add_score(Tank.t(), integer(), reason()) :: Tank.t()
  def add_score(tank, _, :grenade), do: tank

  def add_score(%Tank{score: score} = tank, points, _) when is_integer(points),
    do: %{tank | score: score + points}
end
