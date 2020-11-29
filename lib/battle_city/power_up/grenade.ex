defmodule BattleCity.PowerUp.Grenade do
  @moduledoc false

  use BattleCity.PowerUp, duration: :instant

  @impl true
  def on(%Context{enemies: enemies, players: players} = ctx, %Tank{enemy?: enemy?} = tank) do
    ctx =
      if enemy? do
        %{ctx | players: Enum.map(players, &destroy(&1, tank))}
      else
        %{ctx | enemies: Enum.map(enemies, &destroy(&1, tank))}
      end

    {:context, ctx}
  end

  defp destroy(%Tank{} = tank, %Tank{} = killer) do
    Tank.kill(tank, killer, :grenade)
  end
end
