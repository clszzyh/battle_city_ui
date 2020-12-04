defmodule BattleCity.Context do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Business.Generate
  alias BattleCity.Config
  alias BattleCity.Position
  alias BattleCity.PowerUp
  alias BattleCity.Stage
  alias BattleCity.Tank

  @typep state :: :started | :paused | :game_over | :complete
  @typep object_struct :: PowerUp.t() | Tank.t() | Bullet.t() | nil
  @typep object_keys :: :power_ups | :tanks | :bullets
  @typep object :: {object_keys, BattleCity.id()}

  @object_struct_map %{PowerUp => :power_ups, Tank => :tanks, Bullet => :bullets}
  @object_values Map.values(@object_struct_map)

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
      opts
      |> Map.merge(%{enemy?: false, x: :x_player_1, y: :y_player_1, direction: :up})
      |> tank.new()

    %__MODULE__{stage: stage, objects: Position.objects()}
    |> put_object(player)
    |> Generate.add_bot(opts)
  end

  @spec put_object({__MODULE__.t(), object_struct}) :: __MODULE__.t()
  def put_object({ctx, obj}), do: put_object(ctx, obj)

  @spec put_object(__MODULE__.t(), object_struct | [object_struct]) :: __MODULE__.t()
  def put_object(ctx, nil), do: ctx
  def put_object(ctx, []), do: ctx
  def put_object(ctx, [o | rest]), do: ctx |> put_object(o) |> put_object(rest)
  def put_object(ctx, %Tank{dead?: true, id: id}), do: delete_object(ctx, :tanks, id)

  def put_object(ctx, %Bullet{dead?: true, id: id, tank_id: tank_id}) do
    ctx
    |> update_object_raw(:tanks, tank_id, fn x -> %{x | shootable?: true} end)
    |> delete_object(:bullets, id)
  end

  def put_object(
        %__MODULE__{objects: objects} = ctx,
        %{
          position: %{} = position,
          id: id,
          __struct__: struct
        } = o
      ) do
    key = Map.fetch!(@object_struct_map, struct)
    map = ctx |> Map.fetch!(key) |> Map.put(id, o)

    {x, y} = Position.round(position)
    o = objects |> Map.fetch!({x, y}) |> MapSet.put({key, id})
    Map.merge(ctx, %{key => map, :objects => Map.put(objects, {x, y}, o)})
  end

  @spec update_object_raw(
          __MODULE__.t(),
          object_keys,
          BattleCity.id(),
          (object_struct -> object_struct)
        ) :: __MODULE__.t()
  def update_object_raw(ctx, key, id, f) do
    data = ctx |> Map.fetch!(key)

    data
    |> Map.get(id)
    |> case do
      nil -> ctx
      o -> Map.put(ctx, key, Map.put(data, id, f.(o)))
    end
  end

  @spec delete_object(__MODULE__.t(), object_keys, BattleCity.id()) :: __MODULE__.t()
  def delete_object(%{objects: objects} = ctx, key, id) when key in @object_values do
    data = ctx |> Map.fetch!(key)

    data
    |> Map.get(id)
    |> case do
      nil ->
        ctx

      o ->
        xy = {o.position.x, o.position.y}
        o = objects |> Map.fetch!(xy) |> MapSet.delete({key, id})
        ctx |> Map.merge(%{key => Map.delete(data, id), :objects => Map.put(objects, xy, o)})
    end
  end
end
