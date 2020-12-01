defmodule BattleCity.Tank do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Config
  alias BattleCity.Context
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
    @callback handle_bullet(Tank.t(), Event.t()) :: Bullet.t()

    defmacro __using__(opt \\ []) do
      obj = struct!(__MODULE__, opt)

      quote location: :keep do
        alias BattleCity.Tank

        @impl true
        def handle_level_up(_), do: nil

        @impl true
        def handle_bullet(tank, event), do: Tank.default_handle_bullet(tank, event)

        init_ast(unquote(__MODULE__), __MODULE__, unquote(Macro.escape(obj)))
      end
    end
  end

  @type reason :: atom()

  @type t :: %__MODULE__{
          __module__: module(),
          meta: Base.t(),
          id: BattleCity.id(),
          killer: BattleCity.id(),
          position: Position.t(),
          lifes: integer(),
          score: integer(),
          reason: reason(),
          enemy?: boolean(),
          hiden?: boolean(),
          shield?: boolean(),
          freezed?: boolean(),
          shootable?: boolean(),
          dead?: boolean()
        }

  @enforce_keys [:meta, :__module__, :id, :position]
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
    freezed?: false,
    lifes: Config.life_count()
  ]

  @spec default_handle_bullet(__MODULE__.t(), Event.t()) :: Bullet.t()
  def default_handle_bullet(
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

  @spec levelup(Context.t(), __MODULE__.t()) :: __MODULE__.t()
  def levelup(_, %__MODULE__{__module__: module} = target) do
    case module.handle_level_up(target) do
      nil -> target
      level_up_module -> %{target | __module__: level_up_module, meta: level_up_module.init([])}
    end
  end

  @spec operate(Context.t(), __MODULE__.t(), Event.t()) :: BattleCity.invoke_result()
  def operate(_, %__MODULE__{shootable?: false}, %Event{name: :shoot}) do
    {:error, :disabled}
  end

  def operate(
        %Context{bullets: bullets, tanks: tanks} = ctx,
        %__MODULE__{__module__: module, id: tank_id} = tank,
        %Event{name: :shoot} = event
      ) do
    %Bullet{id: bullet_id} = bullet = module.handle_bullet(tank, event)

    %{
      ctx
      | bullets: Map.put(bullets, bullet_id, bullet),
        tanks: Map.put(tanks, tank_id, %{tank | shootable?: false})
    }
  end
end
