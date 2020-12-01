defmodule BattleCity.Business.Bot do
  @moduledoc false

  alias BattleCity.Context
  alias BattleCity.Stage
  alias BattleCity.Tank

  @type time :: 1..4

  @times_map %{
    1 => 4,
    2 => 4,
    3 => 4,
    4 => 4,
    5 => 4
  }

  @times Map.keys(@times_map)

  @spec add_bot(Context.t(), time()) :: Context.t()
  def add_bot(%Context{stage: %{bots: bots} = stage} = ctx, time) when time in @times do
    {tanks, bots} = generate(bots, @times_map[time])
    %{ctx | stage: %{stage | bots: bots}} |> Context.put_tank(tanks)
  end

  @spec generate(Stage.bots(), integer()) :: {[Tank.t()], Stage.bots()}
  defp generate(bots, size) do
    Enum.map_reduce(1..size, bots, &map_reduce_bot/2)
  end

  @spec generate(integer(), Stage.bots()) :: {Tank.t(), Stage.bots()}
  defp map_reduce_bot(_, bots) do
    {module, size} = bots |> Enum.reject(&match?({_, 0}, &1)) |> Enum.random()
    {module.new, Keyword.put(bots, module, size - 1)}
  end
end
