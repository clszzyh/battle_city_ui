defmodule BattleCity.Position do
  @moduledoc false

  @type direction :: :up | :down | :left | :right
  @type x :: 0..12
  @type y :: 0..12

  @type t :: %__MODULE__{
          direction: direction(),
          x: x(),
          y: y()
        }

  @enforce_keys [:x, :y, :direction]
  defstruct [
    :direction,
    :x,
    :y
  ]
end
