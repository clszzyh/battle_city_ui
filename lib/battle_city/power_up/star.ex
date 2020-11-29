defmodule BattleCity.PowerUp.Star do
  @moduledoc false

  use BattleCity.PowerUp

  @impl true
  def effect(%Game{} = o) do
    o
  end
end
