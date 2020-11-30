defmodule BattleCity.Tank do
  @moduledoc false

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
          reason: reason(),
          enemy?: boolean(),
          hiden?: boolean(),
          shield?: boolean(),
          freezed?: boolean(),
          dead?: boolean()
        }

  defstruct [
    :tank,
    :reason,
    :id,
    :killer,
    :lifes,
    dead?: false,
    shield?: false,
    enemy?: true,
    hiden?: false,
    freezed?: false
  ]

  def kill(%__MODULE__{} = o, %__MODULE__{id: killer_id}, reason \\ :normal) do
    %{o | dead?: true, reason: reason, killer: killer_id}
  end
end
