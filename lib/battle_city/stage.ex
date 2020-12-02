defmodule BattleCity.Stage do
  @moduledoc false

  alias BattleCity.Compile
  alias BattleCity.Environment

  @type bots :: [{atom(), integer()}]

  @type t :: %__MODULE__{
          __module__: module,
          name: binary(),
          difficulty: integer(),
          map: [[Environment.t()]],
          bots: bots
        }

  @derive {Inspect, except: [:map]}
  @enforce_keys [:name, :difficulty, :map, :bots]
  defstruct [
    :__module__,
    :name,
    :difficulty,
    :map,
    :bots
  ]

  use BattleCity.StructCollect

  @callback name :: binary()

  defmacro __using__(opt) do
    obj = struct!(__MODULE__, Compile.validate_stage!(Map.new(opt)))

    quote location: :keep do
      init_ast(unquote(__MODULE__), __MODULE__, unquote(Macro.escape(obj)))

      @impl true
      def name, do: unquote(opt[:name])

      @after_compile unquote(__MODULE__)
    end
  end

  def __after_compile__(env, _bytecode) do
    BattleCity.StageCache.put_stage(env.module)
  end
end
