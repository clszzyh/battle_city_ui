defmodule BattleCity.Business.Core do
  @moduledoc false

  alias BattleCity.Context
  alias BattleCity.Tank

  @spec next(Context.t()) :: Context.t()
  def next(%Context{} = ctx) do
    ctx |> next_tanks()
  end

  @spec next_tanks(Context.t()) :: Context.t()
  defp next_tanks(%Context{tanks: tanks} = ctx) do
    {tanks, ctx} = Enum.map_reduce(tanks, ctx, &next_tank_1/2)
    ctx |> Context.put_tank(tanks)
  end

  @spec next_tank_1(Tank.t(), Context.t()) :: {Tank.t() | nil, Context.t()}
  defp next_tank_1(%Tank{dead?: true}, %Context{} = ctx) do
    {nil, ctx}
  end

  defp next_tank_1(%Tank{} = tank, %Context{} = ctx) do
    {tank, ctx}
  end
end
