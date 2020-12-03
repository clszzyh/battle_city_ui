defmodule BattleCity.Bullet do
  @moduledoc false

  alias BattleCity.Position

  @type t :: %__MODULE__{
          speed: Position.speed(),
          position: Position.t(),
          id: BattleCity.id(),
          tank_id: BattleCity.id(),
          event_id: BattleCity.id()
        }

  @enforce_keys [:id, :speed, :position, :tank_id, :event_id]
  defstruct [
    :speed,
    :position,
    :id,
    :tank_id,
    :event_id
  ]
end
