defmodule BattleCity.Business.Bot do
  @moduledoc false

  alias BattleCity.Context
  alias BattleCity.Stage
  alias BattleCity.Tank

  @count 4

  @spec add_bot(Context.t(), map()) :: BattleCity.invoke_result()
  def add_bot(%Context{stage: %{bots: bots} = stage} = ctx, opts \\ %{}) do
    opts = Map.merge(opts, %{enemy?: true, lifes: 1, direction: :random})
    {tanks, bots} = generate(bots, opts)

    tanks
    |> Enum.reject(&match?(nil, &1))
    |> case do
      [] -> {:error, :empty}
      tanks -> %{ctx | stage: %{stage | bots: bots}} |> Context.put_tank(tanks)
    end
  end

  @spec generate(Stage.bots(), map()) :: {[Tank.t()], Stage.bots()}
  defp generate(bots, opts) do
    count = opts[:bot_count] || @count

    Enum.map_reduce(1..count, bots, fn _index, bots ->
      map_reduce_bot(bots, opts)
    end)
  end

  @spec map_reduce_bot(Stage.bots(), map()) :: {Tank.t(), Stage.bots()}
  defp map_reduce_bot(bots, opts) do
    bots
    |> Enum.reject(&match?({_, 0}, &1))
    |> case do
      [] ->
        {nil, bots}

      new_bots ->
        {module, size} = Enum.random(new_bots)
        {module.new(opts), Keyword.put(bots, module, size - 1)}
    end
  end
end
