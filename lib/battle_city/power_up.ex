defmodule BattleCity.PowerUp do
  @moduledoc """
  """

  alias BattleCity.Context
  alias BattleCity.Tank

  @duration 10

  @type duration :: integer() | :instant

  @type t :: %__MODULE__{__module__: module(), duration: duration()}

  @enforce_keys [:__module__]
  defstruct [:__module__, duration: @duration]

  @type result :: {Context.t(), Tank.t()} | {:context, Context.t()} | {:tank, Tank.t()}

  @callback on(Context.t(), Tank.t()) :: result
  @callback off(Context.t(), Tank.t()) :: result
  @optional_callbacks off: 2

  defmacro __using__(opt \\ []) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      alias BattleCity.Context
      alias BattleCity.Tank

      @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))
      def new, do: @obj
    end
  end
end
