defmodule BattleCity.PowerUp.Life do
  @moduledoc false

  use BattleCity.PowerUp, duration: :instant

  @impl true
  def on(%Context{}, %Tank{lifes: lifes} = tank) do
    {:tank, %{tank | lifes: lifes + 1}}
  end
end
