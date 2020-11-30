defmodule BattleCity.Stage do
  @moduledoc false

  @type map_data :: [term()]
  @type bot :: term()

  @type t :: %__MODULE__{
          name: binary(),
          difficulty: integer(),
          map: map_data,
          bots: [bot]
        }

  defstruct [
    :name,
    :difficulty,
    :map,
    :bots
  ]
end
