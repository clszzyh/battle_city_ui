defmodule BattleCity.Stage do
  @moduledoc false

  alias BattleCity.Compile
  alias BattleCity.Environment

  @typep map_data :: [[Environment.t()]]
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

  use BattleCity.StructCollect

  defmacro __using__(opt) do
    obj = struct!(__MODULE__, Compile.validate_stage!(Map.new(opt)))

    quote location: :keep do
      @obj Map.put(unquote(Macro.escape(obj)), :__module__, __MODULE__)

      init_ast(unquote(__MODULE__), @obj)
    end
  end
end
