defmodule BattleCity.PowerUp.Star do
  @moduledoc false

  use BattleCity.PowerUp

  @impl true
  def handle_on(%Context{}, %Tank{} = tank) do
    Tank.levelup(tank)
  end
end
