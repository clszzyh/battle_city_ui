defmodule BattleCity.Environment do
  @moduledoc false

  alias BattleCity.Tank

  @type t :: %__MODULE__{
          __module__: module(),
          allow_pass_tank: boolean(),
          allow_pass_bullet: boolean,
          allow_destroy: boolean()
        }

  @enforce_keys [:__module__]
  defstruct [
    :__module__,
    allow_pass_tank: false,
    allow_pass_bullet: false,
    allow_destroy: false
  ]

  @callback on(Tank.t()) :: Tank.t()
  @callback off(Tank.t()) :: Tank.t()
  @optional_callbacks on: 1, off: 1

  defmacro __using__(opt \\ []) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      alias BattleCity.Tank

      @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))
      def new, do: @obj
    end
  end
end
