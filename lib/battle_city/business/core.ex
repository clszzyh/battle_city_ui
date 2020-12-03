defmodule BattleCity.Business.Core do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Context
  alias BattleCity.Stage
  alias BattleCity.Tank
  import BattleCity.Position, only: [is_on_border: 1]

  @typep move_struct :: Tank.t() | Bullet.t()

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

  # def move(%{position: %{x: x, y: y} = position} = o, map) do
  #   {xory, xy_real, xy} = Position.vector_with_normalize(position, speed)
  #   case xory do
  #   end
  # end
end
