defmodule BattleCity.PowerUp.Timer do
  @moduledoc false

  use BattleCity.PowerUp

  @impl true
  def on(%Context{} = ctx, %Tank{} = tank) do
    Context.handle_all_enemies(ctx, tank, {:stop, :timer})
  end

  @impl true
  def off(%Context{} = ctx, %Tank{} = tank) do
    Context.handle_all_enemies(ctx, tank, {:resume, :timer})
  end
end
