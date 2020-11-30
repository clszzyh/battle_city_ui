defmodule BattleCity.PowerUp.Star do
  @moduledoc false

  use BattleCity.PowerUp

  @impl true
  def on(%Context{}, %Tank{} = tank) do
    Tank.levelup(tank, 1)
  end
end
