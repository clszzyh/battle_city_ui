defmodule BattleCity.Bullet do
  @moduledoc false

  @type direction :: :up | :down | :left | :right

  @type t :: %__MODULE__{
          speed: integer,
          direction: direction,
          id: BattleCity.id(),
          tank_id: BattleCity.id()
        }

  defstruct [
    :speed,
    :direction,
    :id,
    :tank_id
  ]
end
