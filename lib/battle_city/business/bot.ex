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

  @spec add_bot(Context.t(), time(), map()) :: Context.t()
  def add_bot(%Context{stage: %{bots: bots} = stage} = ctx, time, opts) when time in @times do
    opts = Map.merge(opts, %{enemy?: true, lifes: 1, direction: :down})
    {tanks, bots} = generate(bots, @times_map[time], opts)
    %{ctx | stage: %{stage | bots: bots}} |> Context.put_tank(tanks)
  end

  @spec generate(Stage.bots(), integer(), map()) :: {[Tank.t()], Stage.bots()}
  defp generate(bots, size, opts) do
    Enum.map_reduce(1..size, bots, fn _index, bots ->
      map_reduce_bot(bots, opts)
    end)
  end

  @spec map_reduce_bot(Stage.bots(), map()) :: {Tank.t(), Stage.bots()}
  defp map_reduce_bot(bots, opts) do
    {module, size} = bots |> Enum.reject(&match?({_, 0}, &1)) |> Enum.random()
    {module.new(opts), Keyword.put(bots, module, size - 1)}
  end
end
