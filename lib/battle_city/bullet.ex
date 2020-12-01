defmodule BattleCity.Bullet do
  @moduledoc false

  alias BattleCity.Position

  @type t :: %__MODULE__{
          speed: integer,
          position: Position.t(),
          id: BattleCity.id(),
          tank_id: BattleCity.id()
        }

  @enforce_keys [:direction, :speed, :position]
  defstruct [
    :speed,
    :position,
    :id,
    :tank_id
  ]
end
