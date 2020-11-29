defmodule BattleCity.PowerUp.Star do
  @moduledoc false

  use BattleCity.PowerUp

  @impl true
  def on(%Context{} = ctx, %Tank{} = tank) do
    {ctx, tank}
  end
end
