defmodule BattleCity.Tank do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Config

  defmodule Base do
    alias BattleCity.Tank
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

    @callback handle_level_up(Tank.t()) :: module()
    @callback handle_bullet(Bullet.t()) :: Bullet.t()
    @optional_callbacks handle_bullet: 1

    defmacro __using__(opt \\ []) do
      quote location: :keep do
        @behaviour unquote(__MODULE__)
        alias BattleCity.Tank

        @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))
        @spec new :: unquote(__MODULE__).t
        def new, do: @obj

        def handle_level_up(_), do: nil

        defoverridable unquote(__MODULE__)
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

  @spec levelup(__MODULE__.t()) :: __MODULE__.t()
  def levelup(%__MODULE__{tank: %{__module__: module}} = target) do
    case module.handle_level_up(target) do
      nil -> target
      level_up_module -> %{target | tank: level_up_module.new}
    end
  end
end
