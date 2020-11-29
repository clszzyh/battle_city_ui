defmodule BattleCity.Tank do
  @moduledoc false
  @type blood :: number
  @type speed :: number
  @type bullet_speed :: number
  @type bullet_damage :: number
  @type t :: %__MODULE__{
          blood: blood,
          speed: speed,
          bullet_speed: bullet_speed,
          bullet_damage: bullet_damage
        }

  @enforce_keys []
  defstruct [
    :blood,
    :speed,
    :bullet_speed,
    :bullet_damage
  ]
end
