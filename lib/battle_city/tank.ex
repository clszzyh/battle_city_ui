defmodule BattleCity.Tank do
  @moduledoc false

  alias BattleCity.Action
  alias BattleCity.Bullet
  alias BattleCity.Config
  alias BattleCity.Event
  alias BattleCity.Position
  alias BattleCity.Utils
  alias __MODULE__

  @type health :: 1..10
  @type points :: integer
  @type level :: 1..4

  defmodule Base do
    @type t :: %__MODULE__{
            __module__: module,
            level: Tank.level(),
            points: Tank.points(),
            health: Tank.health(),
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

    @callback name :: atom()

    def __color__, do: "#111111"

    defmacro __using__(opt \\ []) do
      obj = struct(__MODULE__, opt)
      keys = Map.keys(Tank.__struct__())

      quote location: :keep do
        alias BattleCity.Tank

        @impl true
        def handle_level_up(_), do: nil

        @impl true
        def create_bullet(tank, event), do: Tank.default_create_bullet(tank, event)

        @impl true
        def name, do: Utils.module_name(__MODULE__)

        @impl true
        def new(map \\ %{}) do
          meta = init(map)

          data = %{
            __module__: __MODULE__,
            meta: meta,
            position:
              Position.init(
                map
                |> Map.merge(%{__parent__: unquote(__MODULE__), __module__: __MODULE__})
              ),
            speed: meta.move_speed * Position.speed(),
            health: meta.health
          }

          struct!(Tank, map |> Map.take(unquote(keys)) |> Map.merge(data))
        end

        init_ast(unquote(__MODULE__), __MODULE__, unquote(Macro.escape(obj)), unquote(opt))
      end
    end
  end

  @type t :: %__MODULE__{
          __module__: module(),
          meta: Base.t(),
          id: BattleCity.id(),
          __actions__: [Action.t()],
          position: Position.t(),
          speed: Position.speed(),
          lifes: integer(),
          score: integer(),
          health: health(),
          reason: BattleCity.reason(),
          enemy?: boolean(),
          hiden?: boolean(),
          shield?: boolean(),
          moving?: boolean(),
          freezed?: boolean(),
          shootable?: boolean(),
          changed?: boolean(),
          dead?: boolean()
        }

  @enforce_keys [:meta, :__module__, :position]
  @derive {SimpleDisplay, only: [:id, :__module__, :speed, :health, :score, :lifes]}
  defstruct [
    :__module__,
    :meta,
    :id,
    :reason,
    :position,
    :speed,
    :health,
    score: 0,
    dead?: false,
    shield?: false,
    enemy?: true,
    shootable?: true,
    hiden?: false,
    moving?: false,
    changed?: true,
    freezed?: false,
    __actions__: [],
    lifes: Config.life_count()
  ]

  @spec default_create_bullet(__MODULE__.t(), Event.t()) :: Bullet.t()
  def default_create_bullet(
        %__MODULE__{
          id: tank_id,
          enemy?: enemy?,
          meta: %{bullet_speed: speed},
          position: position
        },
        %Event{id: event_id}
      ) do
    %Bullet{
      enemy?: enemy?,
      position: position,
      tank_id: tank_id,
      event_id: event_id,
      speed: speed
    }
  end

  @spec hit(__MODULE__.t(), Bullet.t()) :: __MODULE__.t()
  def hit(%__MODULE__{health: health} = tank, %Bullet{power: power}) when power < health do
    %__MODULE__{tank | health: health - power}
  end

  def hit(%__MODULE__{} = tank, %Bullet{}), do: %{tank | dead?: true}
end
