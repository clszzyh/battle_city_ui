defmodule BattleCity.Context do
  @moduledoc false

  alias BattleCity.Stage
  alias BattleCity.Tank

  @type t :: %__MODULE__{
          score: integer,
          lives: integer,
          rest_enemies: integer,
          shovel?: boolean,
          stage: Stage.t(),
          players: [Tank.t()],
          enemies: [Tank.t()]
        }

  @default_lifes 3
  @default_rest_enemies 20

  defstruct [
    :stage,
    :players,
    :enemies,
    rest_enemies: @default_rest_enemies,
    lives: @default_lifes,
    score: 0,
    shovel?: false
  ]

  def handle_all_enemies(
        %__MODULE__{players: players, enemies: enemies} = ctx,
        %Tank{enemy?: enemy?, id: id},
        {op, reason}
      ) do
    {key, tanks} = if enemy?, do: {:players, players}, else: {:enemies, enemies}

    {tanks, ctx} =
      Enum.map_reduce(tanks, ctx, fn target, ctx ->
        apply(__MODULE__, op, [target, ctx, {id, reason}])
      end)

    Map.put(ctx, key, tanks)
  end

  def stop(%Tank{} = target, %__MODULE__{} = ctx, _) do
    {%{target | freezed?: true}, ctx}
  end

  def resume(%Tank{} = target, %__MODULE__{} = ctx, _) do
    {%{target | freezed?: false}, ctx}
  end

  def kill(
        %Tank{tank: %{points: points}} = target,
        %__MODULE__{} = ctx,
        {id, reason}
      ) do
    target = %{target | dead?: true, reason: reason, killer: id}
    ctx = maybe_add_score(ctx, points, reason)

    {target, ctx}
  end

  defp maybe_add_score(ctx, _, :grenade), do: ctx

  defp maybe_add_score(%__MODULE__{score: score} = ctx, points, _),
    do: %{ctx | score: score + points}
end
