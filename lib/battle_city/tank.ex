defmodule BattleCity.Tank do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Config
  alias BattleCity.Event
  alias BattleCity.Position
  alias BattleCity.Utils
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

    @enforce_keys [:level, :points, :health, :move_speed, :bullet_speed]

    defstruct [
      :__module__,
      :level,
      :points,
      :health,
      :move_speed,
      :bullet_speed
    ]

    use BattleCity.StructCollect

    @callback handle_level_up(Tank.t()) :: module()
    @callback create_bullet(Tank.t(), Event.t()) :: Bullet.t()

    @callback new() :: Tank.t()
    @callback new(map) :: Tank.t()

    defmacro __using__(opt \\ []) do
      obj = struct!(__MODULE__, opt)
      keys = Map.keys(Tank.__struct__())

      quote location: :keep do
        alias BattleCity.Tank

        @impl true
        def handle_level_up(_), do: nil

        @impl true
        def create_bullet(tank, event), do: Tank.default_create_bullet(tank, event)

        @impl true
        def new(map \\ %{}) do
          data = %{
            __module__: __MODULE__,
            meta: init(map),
            id: Utils.random(),
            position: Position.init(map)
          }

          struct!(Tank, map |> Map.take(unquote(keys)) |> Map.merge(data))
        end

        init_ast(unquote(__MODULE__), __MODULE__, unquote(Macro.escape(obj)))
      end
    end
  end

  @type t :: %__MODULE__{
          __module__: module(),
          meta: Base.t(),
          id: BattleCity.id(),
          killer: BattleCity.id(),
          position: Position.t(),
          lifes: integer(),
          score: integer(),
          reason: BattleCity.reason(),
          enemy?: boolean(),
          hiden?: boolean(),
          shield?: boolean(),
          moving?: boolean(),
          freezed?: boolean(),
          shootable?: boolean(),
          dead?: boolean()
        }

  @enforce_keys [:meta, :__module__, :position]
  defstruct [
    :__module__,
    :meta,
    :id,
    :reason,
    :killer,
    :position,
    score: 0,
    dead?: false,
    shield?: false,
    enemy?: true,
    shootable?: true,
    hiden?: false,
    moving?: false,
    freezed?: false,
    lifes: Config.life_count()
  ]

  @spec default_create_bullet(__MODULE__.t(), Event.t()) :: Bullet.t()
  def default_create_bullet(
        %__MODULE__{id: tank_id, meta: %{bullet_speed: speed}},
        %Event{id: event_id, position: position}
      ) do
    %Bullet{
      id: Utils.random(),
      position: position,
      tank_id: tank_id,
      event_id: event_id,
      speed: speed
    }
  end
end
