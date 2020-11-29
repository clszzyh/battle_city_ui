defmodule BattleCity.PowerUp do
  @moduledoc """
  """

  alias BattleCity.Game

  @type t :: %__MODULE__{__module__: module()}

  @enforce_keys [:__module__]
  defstruct [:__module__]

  @callback effect(Game.t()) :: Game.t()

  defmacro __using__(opt \\ []) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      alias BattleCity.Game

      @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))
      def new, do: @obj
    end
  end
end
