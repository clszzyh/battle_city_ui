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

  def move(%{position: position, speed: speed} = o, map) do
    %Position{path: [_one | rest] = path} = position = Position.destination(position, speed)
    o = %{o | position: %{position | path: rest}}
    path_map = for p <- path, do: Map.fetch!(map, p)
    path_map |> tl |> Enum.zip(path_map) |> Enum.reduce_while(o, &do_move/2)
  end

  @spec do_move({Environment.t(), Environment.t()}, move_struct) ::
          {:halt, atom()} | {:cont, move_struct}
  defp do_move({target, source}, o) do
    with {:ok, new_o} <- Environment.enter(target, o),
         {:ok, new_o} <- Environment.leave(source, new_o),
         new_o <- Environment.copy_xy(target, new_o) do
      {:cont, new_o}
    else
      {:error, reason} ->
        {:halt, Environment.copy_rxy(source, %{o | reason: reason})}
    end
  end
end
