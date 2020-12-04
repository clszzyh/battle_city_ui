defmodule BattleCity.Business.Move do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Context
  alias BattleCity.Environment
  alias BattleCity.Position
  alias BattleCity.Stage
  alias BattleCity.Tank
  import BattleCity.Position, only: [is_on_border: 1]

  @typep move_struct :: Environment.object()

  @spec move_all(Context.t()) :: Context.t()
  def move_all(%Context{} = ctx) do
    bullets = Enum.map(ctx.bullets, &move(elem(&1, 1), ctx.stage.map))
    tanks = Enum.map(ctx.tanks, &move(elem(&1, 1), ctx.stage.map))
    ctx |> Context.put_object(bullets) |> Context.put_object(tanks)
  end

  @spec move(move_struct, Stage.map_data()) :: move_struct
  def move(%Bullet{position: position} = bullet, _) when is_on_border(position),
    do: %{bullet | dead?: true}

  def move(%Tank{position: position} = tank, _) when is_on_border(position), do: tank
  def move(%Tank{dead?: true} = tank, _), do: tank
  def move(%Tank{moving?: false} = tank, _), do: tank
  def move(%Tank{freezed?: true} = tank, _), do: tank

  def move(%{position: %{x: x, y: y} = position, speed: speed} = o, map) do
    {xory, xy_map, xy} = Position.vector_with_normalize(position, speed)

    path =
      case xory do
        :x -> for i <- x..xy, do: Map.fetch!(map, {i, y})
        :y -> for i <- y..xy, do: Map.fetch!(map, {x, i})
      end

    o = %{o | position: Map.merge(position, xy_map)}
    path |> tl |> Enum.zip(path) |> Enum.reduce_while(o, &do_move/2)
  end

  @spec do_move({Environment.t(), Environment.t()}, move_struct) ::
          {:halt, atom()} | {:cont, move_struct}
  defp do_move({target, source}, o) do
    with {:ok, new_o} <- Environment.enter(target, o),
         {:ok, new_o} <- Environment.leave(source, new_o),
         {:ok, new_o} <- Environment.copy_xy(target, new_o) do
      {:cont, new_o}
    else
      {:error, _reason} ->
        {:halt, o}
    end
  end
end
