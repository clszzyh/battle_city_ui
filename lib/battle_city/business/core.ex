defmodule BattleCity.Business.Core do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Context
  alias BattleCity.Tank
  import BattleCity.Position, only: [is_on_border: 1]

  @type move_object :: Tank.t() | Bullet.t()

  @spec next(Context.t()) :: Context.t()
  def next(%Context{} = ctx) do
    ctx |> next_tanks()
  end

  @spec next_tanks(Context.t()) :: Context.t()
  defp next_tanks(%Context{tanks: tanks} = ctx) do
    {tanks, ctx} = Enum.map_reduce(tanks, ctx, &next_tank_1/2)
    ctx |> Context.put_object(tanks)
  end

  @spec next_tank_1(Tank.t(), Context.t()) :: {Tank.t() | nil, Context.t()}
  defp next_tank_1(%Tank{dead?: true}, %Context{} = ctx) do
    {nil, ctx}
  end

  defp next_tank_1(%Tank{moving?: true} = tank, %Context{} = ctx) do
    {Map.put(move(tank, ctx), :moving?, false), ctx}
  end

  defp next_tank_1(%Tank{} = tank, %Context{} = ctx) do
    {tank, ctx}
  end

  @spec move(move_object, Context.t()) :: move_object
  def move(%Tank{freezed?: true} = tank, _), do: tank
  def move(%{position: position} = o, _) when is_on_border(position), do: o

  def move(%{position: _position} = o, _) do
    o
  end
end
