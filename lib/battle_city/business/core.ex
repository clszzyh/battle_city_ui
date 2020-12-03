defmodule BattleCity.Business.Core do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Context
  alias BattleCity.Stage
  alias BattleCity.Tank
  import BattleCity.Position, only: [is_on_border: 1]

  @type move_struct :: Tank.t() | Bullet.t()

  @spec next(Context.t()) :: Context.t()
  def next(%Context{} = ctx) do
    ctx |> move_objects()
  end

  @spec move_objects(Context.t()) :: Context.t()
  def move_objects(%Context{} = ctx) do
    bullets = Enum.map(ctx.bullets, &move(elem(&1, 1), ctx.stage.map))
    tanks = Enum.map(ctx.tanks, &move(elem(&1, 1), ctx.stage.map))
    ctx |> Context.put_object(bullets) |> Context.put_object(tanks)
  end

  @spec move(move_struct, Stage.map_data()) :: move_struct
  def move(%Bullet{position: position}, _) when is_on_border(position), do: nil
  def move(%Tank{position: position} = tank, _) when is_on_border(position), do: tank
  def move(%Tank{dead?: true}, _), do: nil
  def move(%Tank{moving?: false} = tank, _), do: tank
  def move(%Tank{freezed?: true} = tank, _), do: tank

  def move(%{position: _position} = o, _map) do
    o
  end
end
