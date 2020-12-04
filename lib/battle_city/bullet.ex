defmodule BattleCity.Bullet do
  @moduledoc false

  alias BattleCity.Action
  alias BattleCity.Position

  @type t :: %__MODULE__{
          speed: Position.speed(),
          position: Position.t(),
          id: BattleCity.id(),
          __actions__: [Action.t()],
          tank_id: BattleCity.id(),
          event_id: BattleCity.id(),
          reason: BattleCity.reason(),
          enemy?: boolean(),
          hidden?: boolean(),
          dead?: boolean()
        }

  @enforce_keys [:id, :speed, :position, :tank_id, :event_id, :enemy?]
  defstruct [
    :speed,
    :position,
    :id,
    :reason,
    :tank_id,
    :event_id,
    :enemy?,
    __actions__: [],
    hidden?: false,
    dead?: false
  ]
end
