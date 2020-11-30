defmodule BattleCity.PowerUp.Helmet do
  @moduledoc false

  use BattleCity.PowerUp

  @impl true
  def on(%Context{}, %Tank{} = tank) do
    %{tank | shield?: true}
  end

  @impl true
  def off(%Context{}, %Tank{} = tank) do
    %{tank | shield?: false}
  end
end
