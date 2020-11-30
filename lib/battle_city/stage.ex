defmodule BattleCity.Stage do
  @moduledoc false

  @type map_data :: [term()]
  @type bot :: term()

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

  def parse_map(o) do
    o
  end

  def parse_bot(o) do
    o
  end
end
