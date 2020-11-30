defmodule BattleCity.Tank do
  @moduledoc false

  alias BattleCity.Config

  defmodule Base do
    @type health :: 1..10
    @type move_speed :: 1..10
    @type bullet_speed :: move_speed
    @type points :: integer
    @type level :: 1..4

    @type t :: %__MODULE__{
            __module__: module,
            level: level(),
            points: points(),
            health: health(),
            move_speed: move_speed(),
            bullet_speed: bullet_speed()
          }

    @enforce_keys []
    defstruct [
      :__module__,
      :points,
      :health,
      :move_speed,
      :bullet_speed,
      level: 1
    ]

    defmacro __using__(opt \\ []) do
      quote location: :keep do
        # @behaviour unquote(__MODULE__)
        alias BattleCity.Tank

        @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))
        def new, do: @obj
      end
    end
  end

  @type reason :: atom()

  @type t :: %__MODULE__{
          tank: Base.t(),
          id: BattleCity.tank_id(),
          killer: BattleCity.tank_id(),
          lifes: integer(),
          score: integer(),
          reason: reason(),
          enemy?: boolean(),
          hiden?: boolean(),
          shield?: boolean(),
          freezed?: boolean(),
          dead?: boolean()
        }

  defstruct [
    :tank,
    :id,
    :reason,
    :killer,
    score: 0,
    dead?: false,
    shield?: false,
    enemy?: true,
    hiden?: false,
    freezed?: false,
    lifes: Config.life_count()
  ]

  def levelup(%__MODULE__{} = tank, _level \\ 1) do
    tank
  end
end
