defmodule BattleCity.PowerUp.Grenade do
  @moduledoc false

  use BattleCity.PowerUp, duration: :instant

  @impl true
  def on(%Context{} = ctx, %Tank{} = tank) do
    Context.handle_all_enemies(ctx, tank, {:kill, :grenade})
  end
end
