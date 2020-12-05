defmodule BattleCity.Stage do
  @moduledoc false

  alias BattleCity.Compile
  alias BattleCity.Environment
  alias BattleCity.Position
  alias BattleCity.Process.StageCache

  @type bots :: [{atom(), integer()}]
  @type map_data :: %{Position.coordinate() => Environment.t()}

  @type t :: %__MODULE__{
          __module__: module,
          name: binary(),
          difficulty: integer(),
          map: map_data,
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
      @impl true
      def name, do: unquote(String.to_integer(opt[:name]))

      init_ast(unquote(__MODULE__), __MODULE__, unquote(Macro.escape(obj)))

      @after_compile unquote(__MODULE__)
    end
  end

  def __after_compile__(env, _bytecode) do
    StageCache.put_stage(env.module)
  end
end
