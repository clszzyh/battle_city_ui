defmodule BattleCity.PowerUp.Shovel do
  @moduledoc false

  use BattleCity.PowerUp, duration: :instant

  @impl true
  def on(%Context{} = ctx, %Tank{}) do
    {:context, %{ctx | shovel?: true}}
  end

  @impl true
  def off(%Context{} = ctx, %Tank{}) do
    {:context, %{ctx | shovel?: false}}
  end
end
