defmodule BattleCity.Context do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Config
  alias BattleCity.Stage
  alias BattleCity.Tank

  @type t :: %__MODULE__{
          rest_enemies: integer,
          shovel?: boolean,
          stage: Stage.t(),
          tanks: %{BattleCity.id() => Tank.t()},
          bullets: %{BattleCity.id() => Bullet.t()}
        }

  defstruct [
    :stage,
    :tanks,
    :bullets,
    rest_enemies: Config.rest_enemies(),
    shovel?: false
  ]

  @type op :: :kill | :stop | :resume
  @type reason :: atom
  @typep reduce_map_result :: {Tank.t(), {__MODULE__.t(), Tank.t()}}

  @spec handle_all_enemies(__MODULE__.t(), Tank.t(), {op, reason}) :: __MODULE__.t()
  def handle_all_enemies(
        %__MODULE__{tanks: tanks} = ctx,
        %Tank{id: id} = tank,
        {op, reason}
      ) do
    {tanks, {ctx, tank}} =
      Enum.map_reduce(tanks, {ctx, tank}, fn {_id, target}, {ctx, tank} ->
        reduce_op(op, target, ctx, tank, reason)
      end)

    tanks = Enum.into(tanks, %{}, &{&1.id, &1}) |> Map.put(id, tank)

    %{ctx | tanks: tanks}
  end

  @spec reduce_op(op, Tank.t(), __MODULE__.t(), Tank.t(), reason) :: reduce_map_result
  defp reduce_op(
         _,
         %Tank{enemy?: enemy?} = target,
         %__MODULE__{} = ctx,
         %Tank{enemy?: enemy?} = tank,
         _
       ) do
    {target, {ctx, tank}}
  end

  defp reduce_op(:stop, %Tank{} = target, %__MODULE__{} = ctx, tank, _) do
    {%{target | freezed?: true}, {ctx, tank}}
  end

  defp reduce_op(:resume, %Tank{} = target, %__MODULE__{} = ctx, tank, _) do
    {%{target | freezed?: false}, {ctx, tank}}
  end

  defp reduce_op(
         :kill,
         %Tank{meta: %{points: points}} = target,
         %__MODULE__{} = ctx,
         %Tank{id: id} = tank,
         reason
       ) do
    target = %{target | dead?: true, reason: reason, killer: id}
    tank = add_score(tank, points, reason)

    {target, {ctx, tank}}
  end

  @spec add_score(Tank.t(), integer(), reason) :: Tank.t()
  defp add_score(tank, _, :grenade), do: tank
  defp add_score(%Tank{score: score} = tank, points, _), do: %{tank | score: score + points}
end
