defmodule BattleCity.Tank do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Config
  alias __MODULE__

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

    defstruct [
      :__module__,
      :points,
      :health,
      :move_speed,
      :bullet_speed,
      level: 1
    ]

    use BattleCity.StructCollect

    @callback handle_level_up(Tank.t()) :: module()
    @callback handle_bullet(Bullet.t()) :: Bullet.t()
    @optional_callbacks handle_bullet: 1

    defmacro __using__(opt \\ []) do
      quote location: :keep do
        @behaviour unquote(__MODULE__)
        alias BattleCity.Tank

        @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))

        @impl true
        def init, do: @obj

        @impl true
        def init(keyword), do: Enum.into(keyword, @obj)

        @impl true
        def handle_level_up(_), do: nil

        defoverridable unquote(__MODULE__)
      end
    end
  end

  @type reason :: atom()

  @type t :: %__MODULE__{
          meta: Base.t(),
          id: BattleCity.id(),
          killer: BattleCity.id(),
          lifes: integer(),
          score: integer(),
          reason: reason(),
          enemy?: boolean(),
          hiden?: boolean(),
          shield?: boolean(),
          freezed?: boolean(),
          dead?: boolean()
        }

  @enforce_keys [:meta]
  defstruct [
    :meta,
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
  def levelup(%__MODULE__{meta: %{__module__: module}} = target) do
    case module.handle_level_up(target) do
      nil -> target
      level_up_module -> %{target | meta: level_up_module.init([])}
    end
  end
end
