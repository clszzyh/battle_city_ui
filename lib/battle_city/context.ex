defmodule BattleCity.Context do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Config
  alias BattleCity.Stage
  alias BattleCity.Tank

  @type t :: %__MODULE__{
          rest_enemies: integer,
          shovel?: boolean,
          stage: Stage.t(),
          tanks: %{BattleCity.id() => Tank.t()},
          bullets: %{BattleCity.id() => Bullet.t()}
        }

  defstruct [
    :stage,
    :tanks,
    :bullets,
    rest_enemies: Config.rest_enemies(),
    shovel?: false
  ]

  @spec put_tank({__MODULE__.t(), Tank.t()}) :: __MODULE__.t()
  def put_tank({%__MODULE__{} = ctx, %Tank{} = tank}) do
    put_tank(ctx, tank)
  end

  @spec put_tank(__MODULE__.t(), Tank.t()) :: __MODULE__.t()
  def put_tank(%__MODULE__{tanks: tanks} = ctx, %Tank{id: id} = tank) do
    %{ctx | tanks: Map.put(tanks, id, tank)}
  end

  @spec put_bullet({__MODULE__.t(), Bullet.t()}) :: __MODULE__.t()
  def put_bullet({%__MODULE__{} = ctx, %Bullet{} = tank}) do
    put_bullet(ctx, tank)
  end

  @spec put_bullet(__MODULE__.t(), Bullet.t()) :: __MODULE__.t()
  def put_bullet(%__MODULE__{bullets: bullets} = ctx, %Bullet{id: id} = bullet) do
    %{ctx | bullets: Map.put(bullets, id, bullet)}
  end
end
