defmodule BattleCity.Context do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Business.Generate
  alias BattleCity.Config
  alias BattleCity.Position
  alias BattleCity.PowerUp
  alias BattleCity.Stage
  alias BattleCity.Tank

  @type state :: :started | :paused | :game_over | :complete

  @type object_struct :: PowerUp.t() | Tank.t() | Bullet.t() | nil
  @type object_type :: PowerUp | Tank | Bullet
  @type object :: {object_type, BattleCity.id()}

  @type t :: %__MODULE__{
          rest_enemies: integer,
          shovel?: boolean,
          state: state(),
          objects: %{Position.xy() => MapSet.t(object)},
          stage: Stage.t(),
          power_ups: %{BattleCity.id() => PowerUp.t()},
          tanks: %{BattleCity.id() => Tank.t()},
          bullets: %{BattleCity.id() => Bullet.t()}
        }

  @enforce_keys [:stage, :objects]
  defstruct [
    :stage,
    tanks: %{},
    bullets: %{},
    power_ups: %{},
    objects: %{},
    rest_enemies: Config.rest_enemies(),
    state: :started,
    shovel?: false
  ]

  @spec init(module(), module(), map()) :: __MODULE__.t()
  def init(module, tank \\ Tank.Level1, opts \\ %{}) when is_atom(module) do
    stage = module.init(opts)

    player =
      tank.new(Map.merge(opts, %{enemy?: false, x: :x_player_1, y: :y_player_1, direction: :up}))

    %__MODULE__{stage: stage, objects: Position.objects()}
    |> put_tank(player)
    |> Generate.add_bot(opts)
  end

  @spec put_object(__MODULE__.t(), object_struct) :: __MODULE__.t()
  def put_object(
        %__MODULE__{objects: objects} = ctx,
        %{position: %{x: x, y: y}, id: id, __struct__: struct}
      ) do
    o = objects[{x, y}] |> MapSet.put({id, struct})
    %{ctx | objects: Map.put(objects, {x, y}, o)}
  end

  @spec put_tank({__MODULE__.t(), Tank.t()}) :: __MODULE__.t()
  def put_tank({%__MODULE__{} = ctx, %Tank{} = tank}) do
    put_tank(ctx, tank)
  end

  @spec put_tank(__MODULE__.t(), Tank.t() | [nil | Tank.t()]) :: __MODULE__.t()
  def put_tank(%__MODULE__{tanks: tanks} = ctx, %Tank{id: id} = tank) do
    %{ctx | tanks: Map.put(tanks, id, tank)} |> put_object(tank)
  end

  def put_tank(ctx, [nil | rest]), do: ctx |> put_tank(rest)
  def put_tank(ctx, [tank | rest]), do: ctx |> put_tank(tank) |> put_tank(rest)
  def put_tank(ctx, []), do: ctx

  @spec put_powerup(__MODULE__.t(), PowerUp.t()) :: __MODULE__.t()
  def put_powerup(%__MODULE__{power_ups: power_ups} = ctx, %PowerUp{id: id} = power_up) do
    %{ctx | power_ups: Map.put(power_ups, id, power_up)} |> put_object(power_up)
  end

  @spec put_bullet({__MODULE__.t(), Bullet.t()}) :: __MODULE__.t()
  def put_bullet({%__MODULE__{} = ctx, %Bullet{} = tank}) do
    put_bullet(ctx, tank)
  end

  @spec put_bullet(__MODULE__.t(), Bullet.t()) :: __MODULE__.t()
  def put_bullet(%__MODULE__{bullets: bullets} = ctx, %Bullet{id: id} = bullet) do
    %{ctx | bullets: Map.put(bullets, id, bullet)} |> put_object(bullet)
  end
end
