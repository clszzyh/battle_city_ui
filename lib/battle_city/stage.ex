defmodule BattleCity.Stage do
  @moduledoc false

  @type map_data :: [term()]
  @type bot :: {atom(), integer()}

  @type t :: %__MODULE__{
          __module__: module,
          name: binary(),
          difficulty: integer(),
          map: map_data,
          bots: [bot]
        }

  defstruct [
    :__module__,
    :name,
    :difficulty,
    :map,
    :bots
  ]

  alias BattleCity.Environment
  alias BattleCity.Tank

  @bot_map %{
    "fast" => Tank.Fast,
    "power" => Tank.Power,
    "armor" => Tank.Armor,
    "basic" => Tank.Basic
  }

  @environment_map %{
    "X" => Environment.Blank,
    "B" => Environment.BrickWall,
    "T" => Environment.SteelWall,
    "F" => Environment.Tree,
    "R" => Environment.Water,
    "S" => Environment.Ice,
    "E" => Environment.Home
  }

  defmacro __using__(opt) do
    quote location: :keep do
      @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))
           |> unquote(__MODULE__).validate_data!
      @spec new :: unquote(__MODULE__).t
      def new, do: @obj
    end
  end

  def validate_data!(%__MODULE__{map: map, bots: bots} = o) do
    %{o | map: Enum.map(map, &parse_map/1), bots: Enum.map(bots, &parse_bot/1)}
  end

  defp parse_map(o) do
    result = o |> String.split(" ", trim: true)
    unless Enum.count(result) == 13, do: raise("#{o}'s length should be 13.")
    result |> Enum.map(&parse_map_1/1) |> List.to_tuple()
  end

  defp parse_map_1(o) do
    {prefix, suffix} = parse_map_2(o)
    {Map.fetch!(@environment_map, prefix), suffix}
  end

  defp parse_map_2(<<prefix::binary-size(1), suffix::binary-size(1)>>), do: {prefix, suffix}
  defp parse_map_2(<<prefix::binary-size(1)>>), do: {prefix, nil}

  defp parse_bot(o) do
    [num, kind] = o |> String.split("*")
    num = String.to_integer(num)
    if num <= 0, do: raise("#{o} should > 0.")
    {Map.fetch!(@bot_map, kind), num}
  end
end
