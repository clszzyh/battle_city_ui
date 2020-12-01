defmodule BattleCity.PowerUp.Star do
  @moduledoc false

  use BattleCity.PowerUp

  @impl true
  def handle_on(%Context{} = ctx, %Tank{} = tank) do
    Tank.levelup(ctx, tank)
  end
end
