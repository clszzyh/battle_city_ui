defmodule BattleCity.Context do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Business.Bot
  alias BattleCity.Config
  alias BattleCity.PowerUp
  alias BattleCity.Stage
  alias BattleCity.Tank

  @type state :: :started | :paused | :game_over | :complete

  @type t :: %__MODULE__{
          rest_enemies: integer,
          shovel?: boolean,
          state: state(),
          stage: Stage.t(),
          power_ups: %{BattleCity.id() => PowerUp.t()},
          tanks: %{BattleCity.id() => Tank.t()},
          bullets: %{BattleCity.id() => Bullet.t()}
        }

  @enforce_keys [:stage]
  defstruct [
    :stage,
    tanks: %{},
    bullets: %{},
    power_ups: %{},
    rest_enemies: Config.rest_enemies(),
    state: :started,
    shovel?: false
  ]

  @spec init(module(), module(), map()) :: __MODULE__.t()
  def init(module, tank \\ Tank.Level1, opts \\ %{}) when is_atom(module) do
    stage = module.init(opts)
    player = tank.new(Map.put(opts, :enemy?, false))
    %__MODULE__{stage: stage} |> put_tank(player) |> Bot.add_bot(opts)
  end

  @spec put_tank({__MODULE__.t(), Tank.t()}) :: __MODULE__.t()
  def put_tank({%__MODULE__{} = ctx, %Tank{} = tank}) do
    put_tank(ctx, tank)
  end

  @spec put_tank(__MODULE__.t(), Tank.t() | [nil | Tank.t()]) :: __MODULE__.t()
  def put_tank(%__MODULE__{tanks: tanks} = ctx, %Tank{id: id} = tank) do
    %{ctx | tanks: Map.put(tanks, id, tank)}
  end

  def put_tank(ctx, [nil | rest]), do: ctx |> put_tank(rest)
  def put_tank(ctx, [tank | rest]), do: ctx |> put_tank(tank) |> put_tank(rest)
  def put_tank(ctx, []), do: ctx

  @spec put_bullet({__MODULE__.t(), Bullet.t()}) :: __MODULE__.t()
  def put_bullet({%__MODULE__{} = ctx, %Bullet{} = tank}) do
    put_bullet(ctx, tank)
  end

  @spec put_bullet(__MODULE__.t(), Bullet.t()) :: __MODULE__.t()
  def put_bullet(%__MODULE__{bullets: bullets} = ctx, %Bullet{id: id} = bullet) do
    %{ctx | bullets: Map.put(bullets, id, bullet)}
  end
end
