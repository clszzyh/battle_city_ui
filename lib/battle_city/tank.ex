defmodule BattleCity.Tank do
  @moduledoc false

  alias BattleCity.Action
  alias BattleCity.Bullet
  alias BattleCity.Config
  alias BattleCity.Event
  alias BattleCity.Position
  alias BattleCity.Utils
  alias __MODULE__

  defmodule Base do
    @typep health :: 1..10
    @typep points :: integer
    @typep level :: 1..4

    @type t :: %__MODULE__{
            __module__: module,
            level: level(),
            points: points(),
            health: health(),
            move_speed: Position.speed(),
            bullet_speed: Position.speed()
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
          meta = init(map)

          data = %{
            __module__: __MODULE__,
            meta: meta,
            id: Utils.random(),
            position: Position.init(map),
            speed: meta.move_speed
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
          __actions__: [Action.t()],
          killer: BattleCity.id(),
          position: Position.t(),
          speed: Position.speed(),
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
    :speed,
    score: 0,
    dead?: false,
    shield?: false,
    enemy?: true,
    shootable?: true,
    hiden?: false,
    moving?: false,
    freezed?: false,
    __actions__: [],
    lifes: Config.life_count()
  ]

  @spec default_create_bullet(__MODULE__.t(), Event.t()) :: Bullet.t()
  def default_create_bullet(
        %__MODULE__{id: tank_id, meta: %{bullet_speed: speed}, position: position},
        %Event{id: event_id}
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
