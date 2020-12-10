defmodule BattleCity.Context do
  @moduledoc false

  alias BattleCity.Action
  alias BattleCity.Bullet
  alias BattleCity.Config
  alias BattleCity.Position
  alias BattleCity.PowerUp
  alias BattleCity.Process.GameSupervisor
  alias BattleCity.Stage
  alias BattleCity.Tank

  @typep state :: :started | :paused | :game_over | :complete
  @typep object_struct :: PowerUp.t() | Tank.t() | Bullet.t() | nil

  @object_struct_map %{PowerUp => :power_ups, Tank => :tanks, Bullet => :bullets}
  @object_values Map.values(@object_struct_map)

  @loop_interval 100
  @timeout_interval 1000 * 60 * 60 * 24

  @typep width :: Position.width()
  @typep height :: Position.height()
  @typep color :: Position.color()
  @typep rx :: Position.rx()
  @typep ry :: Position.ry()
  @typep grid :: {rx(), ry(), width(), height(), color()}

  @type t :: %__MODULE__{
          rest_enemies: integer,
          shovel?: boolean,
          loop_interval: integer(),
          timeout_interval: integer(),
          __counters__: map(),
          state: state(),
          grids: %{Position.coordinate() => {width(), height(), color()}},
          objects: %{Position.coordinate() => MapSet.t(BattleCity.fingerprint())},
          stage: Stage.t(),
          power_ups: %{BattleCity.id() => PowerUp.t()},
          tanks: %{BattleCity.id() => Tank.t()},
          bullets: %{BattleCity.id() => Bullet.t()}
        }

  @enforce_keys [:stage, :slug]
  @derive {SimpleDisplay,
           only: [:rest_enemies, :shovel?, :state, :loop_interval, :timeout_interval]}
  defstruct [
    :stage,
    :slug,
    loop_interval: @loop_interval,
    timeout_interval: @timeout_interval,
    grids: %{},
    tanks: %{},
    bullets: %{},
    power_ups: %{},
    objects: %{},
    __counters__: %{player: 0, power_up: 0, bullet: 0, enemy: 0},
    rest_enemies: Config.rest_enemies(),
    state: :started,
    shovel?: false
  ]

  @spec grids(__MODULE__.t()) :: [grid()]
  def grids(%__MODULE__{} = ctx) do
    map_grids(ctx) ++ object_grids(ctx)
  end

  def map_grids(%__MODULE__{grids: grids}) do
    for {_, {rx, ry, width, height, color}} <- grids, do: {rx, ry, width, height, color}
  end

  def object_grids(%__MODULE__{objects: objects} = ctx) do
    for {_, mapset} <- objects, MapSet.size(mapset) > 0, reduce: [] do
      ary ->
        o =
          for {t, id, _} <- mapset do
            %{position: p} = fetch_object!(ctx, t, id)
            {p.rx, p.ry, p.width, p.height, p.color}
          end

        ary ++ o
    end
  end

  def initial_objects(%__MODULE__{stage: %{map: map}} = ctx) do
    grids =
      for {k, %{position: p}} <- map, into: %{}, do: {k, {p.rx, p.ry, p.width, p.height, p.color}}

    %{ctx | objects: Position.objects(), grids: grids}
  end

  @spec put_object({__MODULE__.t(), object_struct}) :: __MODULE__.t()
  def put_object({ctx, obj}), do: put_object(ctx, obj)

  @spec put_object(__MODULE__.t(), object_struct | [object_struct]) :: __MODULE__.t()
  def put_object(ctx, nil), do: ctx
  def put_object(ctx, []), do: ctx
  def put_object(ctx, [o | rest]), do: ctx |> put_object(o) |> put_object(rest)

  def put_object(%{__counters__: %{bullet: i} = c} = ctx, %Bullet{id: nil} = o) do
    put_object(%{ctx | __counters__: %{c | bullet: i + 1}}, %{o | id: "b#{i}"})
  end

  def put_object(%{__counters__: %{power_up: i} = c} = ctx, %PowerUp{id: nil} = o) do
    put_object(%{ctx | __counters__: %{c | power_up: i + 1}}, %{o | id: "p#{i}"})
  end

  def put_object(%{__counters__: %{enemy: i} = c} = ctx, %Tank{id: nil, enemy?: true} = o) do
    put_object(%{ctx | __counters__: %{c | enemy: i + 1}}, %{o | id: "e#{i}"})
  end

  def put_object(%{__counters__: %{player: i} = c} = ctx, %Tank{id: nil, enemy?: false} = o) do
    put_object(%{ctx | __counters__: %{c | player: i + 1}}, %{o | id: "t#{i}"})
  end

  def put_object(ctx, o) do
    ctx |> handle_actions(o.__actions__) |> handle_object(o)
  end

  @spec handle_actions(__MODULE__.t(), [Action.t()]) :: __MODULE__.t()
  def handle_actions(ctx, []), do: ctx
  def handle_actions(ctx, [a | rest]), do: ctx |> Action.handle(a) |> handle_actions(rest)

  @spec handle_object(__MODULE__.t(), object_struct) :: __MODULE__.t()
  def handle_object(ctx, %Tank{dead?: true, id: id}), do: delete_object(ctx, :tanks, id)

  def handle_object(ctx, %Bullet{dead?: true, id: id, tank_id: tank_id}) do
    ctx
    |> update_object_raw(:tanks, tank_id, fn x -> {x, %{x | shootable?: true}} end)
    |> delete_object(:bullets, id)
  end

  def handle_object(ctx, %Tank{changed?: false}), do: ctx

  def handle_object(ctx, %Tank{changed?: true} = tank),
    do: put_changed_object(ctx, %{tank | changed?: false})

  def handle_object(ctx, other), do: put_changed_object(ctx, other)

  @spec put_changed_object(__MODULE__.t(), object_struct) :: __MODULE__.t()
  def put_changed_object(
        %__MODULE__{objects: objects} = ctx,
        %{
          position: %{} = position,
          id: id,
          __struct__: struct
        } = o
      ) do
    key = Map.fetch!(@object_struct_map, struct)
    data = ctx |> Map.fetch!(key)

    _res =
      if struct == Tank and !Map.has_key?(data, id) do
        GameSupervisor.start_tank(ctx.slug, {o.enemy?, id})
      end

    map = data |> Map.put(id, o)

    %{x: x, y: y} = Position.normalize(position)
    o = objects |> Map.fetch!({x, y}) |> MapSet.put(Object.fingerprint(o))
    Map.merge(ctx, %{key => map, :objects => Map.put(objects, {x, y}, o)})
  end

  def fetch_object!(ctx, :t, id), do: fetch_object!(ctx, :tanks, id)
  def fetch_object!(ctx, :p, id), do: fetch_object!(ctx, :power_ups, id)
  def fetch_object!(ctx, :b, id), do: fetch_object!(ctx, :bullets, id)

  def fetch_object!(ctx, key, id) do
    ctx |> Map.fetch!(key) |> Map.fetch!(id)
  end

  @spec update_object_raw(
          __MODULE__.t(),
          BattleCity.object_keys(),
          BattleCity.id(),
          (object_struct -> {object_struct, object_struct})
        ) :: __MODULE__.t()
  def update_object_raw(ctx, key, id, f) do
    data = ctx |> Map.fetch!(key)

    {_, data} = data |> Map.get_and_update!(id, f)
    Map.put(ctx, key, data)
  end

  @spec delete_object(__MODULE__.t(), BattleCity.object_keys(), BattleCity.id()) :: __MODULE__.t()
  def delete_object(%{objects: objects} = ctx, key, id) when key in @object_values do
    data = ctx |> Map.fetch!(key)

    data
    |> Map.get(id)
    |> case do
      nil ->
        ctx

      o ->
        _ = if key == :tanks, do: GameSupervisor.stop_tank(ctx.slug, id)
        xy = {o.position.x, o.position.y}
        o = objects |> Map.fetch!(xy) |> MapSet.delete(Object.fingerprint(o))
        ctx |> Map.merge(%{key => Map.delete(data, id), :objects => Map.put(objects, xy, o)})
    end
  end
end
