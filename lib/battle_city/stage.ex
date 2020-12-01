defmodule BattleCity.Stage do
  @moduledoc false

  alias BattleCity.Compile
  # alias BattleCity.Environment

  @typep map_data :: [term()]
  @typep bot :: {atom(), integer()}

  @type t :: %__MODULE__{
          __module__: module,
          name: binary(),
          difficulty: integer(),
          map: map_data,
          bots: [bot]
        }

  @derive {Inspect, except: [:map]}
  defstruct [
    :__module__,
    :name,
    :difficulty,
    :map,
    :bots
  ]

  defmacro __using__(opt) do
    obj = struct!(__MODULE__, opt) |> Compile.validate_stage!()

    quote location: :keep do
      @obj Map.put(unquote(Macro.escape(obj)), :__module__, __MODULE__)
      @spec new :: unquote(__MODULE__).t
      def new, do: @obj
    end
  end
end
