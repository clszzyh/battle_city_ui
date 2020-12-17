defmodule BattleCity.Context do
  @moduledoc """
  Context
  """

  alias BattleCity.Bullet
  alias BattleCity.Callback
  alias BattleCity.Config
  alias BattleCity.Event
  alias BattleCity.Position
  alias BattleCity.PowerUp
  alias BattleCity.Stage
  alias BattleCity.Tank

  require Logger

  @type callback_fn :: (t() -> t())
  @typep state :: :started | :paused | :game_over | :complete
  @type object_struct :: PowerUp.t() | Tank.t() | Bullet.t() | nil

  @object_struct_map %{PowerUp => :power_ups, Tank => :tanks, Bullet => :bullets}
  @object_values Map.values(@object_struct_map)

  @type t :: %__MODULE__{
          rest_enemies: integer(),
          shovel?: boolean(),
          mock: boolean(),
          level: BattleCity.level(),
          loop_interval: integer(),
          bot_loop_interval: integer(),
          timeout_interval: integer(),
          enable_bot: boolean(),
          __counters__: map(),
          __events__: [Event.t()],
          __opts__: map(),
          __global_callbacks__: [callback_fn],
          ai: module(),
          state: state(),
          objects: %{Position.coordinate() => MapSet.t(BattleCity.fingerprint())},
          stage: Stage.t(),
          power_ups: %{BattleCity.id() => PowerUp.t()},
          tanks: %{BattleCity.id() => Tank.t()},
          bullets: %{BattleCity.id() => Bullet.t()}
        }

  @enforce_keys [
    :stage,
    :level,
    :slug,
    :timeout_interval,
    :loop_interval,
    :bot_loop_interval,
    :enable_bot,
    :mock,
    :ai,
    :__opts__
  ]
  @derive {SimpleDisplay,
           only: [:level, :rest_enemies, :shovel?, :state, :loop_interval, :timeout_interval]}
  defstruct @enforce_keys ++
              [
                tanks: %{},
                bullets: %{},
                power_ups: %{},
                objects: %{},
                __events__: [],
                __global_callbacks__: [],
                __counters__: %{player: 0, power_up: 0, bullet: 0, enemy: 0, event: 0, loop: 0},
                rest_enemies: Config.rest_enemies(),
                state: :started,
                shovel?: false
              ]

  @spec grids(__MODULE__.t()) :: [binary()]
  def grids(%__MODULE__{} = ctx) do
    map_grids(ctx) ++ object_grids(ctx)
  end

  def map_grids(%__MODULE__{stage: %{map: map}}) do
    for {_k, o} <- map, do: Html.grid(o)
  end

  def non_empty_objects(%__MODULE__{objects: objects}) do
    for {xy, mapset} <- objects, MapSet.size(mapset) > 0, reduce: [] do
      ary ->
        o = for {t, id, _} <- mapset, do: {xy, t, id}
        ary ++ o
    end
  end

  def object_grids(%__MODULE__{objects: objects} = ctx) do
    for {_, mapset} <- objects, MapSet.size(mapset) > 0, reduce: [] do
      ary ->
        o = for {t, id, _} <- mapset, do: fetch_object!(ctx, t, id) |> Html.grid()
        ary ++ o
    end
  end

  def initial_objects(%__MODULE__{} = ctx) do
    %{ctx | objects: Position.objects()}
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
    ctx |> handle_actions(o, o.__callbacks__) |> handle_object(%{o | __callbacks__: []})
  end

  @spec handle_actions(__MODULE__.t(), object_struct, [Callback.t()]) :: __MODULE__.t()
  def handle_actions(ctx, _, []), do: ctx

  def handle_actions(ctx, o, [a | rest]) do
    ctx = Callback.handle(a, o, ctx)
    handle_actions(ctx, o, rest)
  end

  @spec handle_object(__MODULE__.t(), object_struct) :: __MODULE__.t()
  def handle_object(ctx, %Tank{dead?: true, id: id}), do: delete_object(ctx, :tanks, id)
  def handle_object(ctx, %Bullet{dead?: true, id: id}), do: delete_object(ctx, :bullets, id)
  def handle_object(ctx, %Tank{changed?: false}), do: ctx

  def handle_object(ctx, %Tank{changed?: true} = tank),
    do: put_changed_object(ctx, %{tank | changed?: false})

  def handle_object(ctx, other), do: put_changed_object(ctx, other)

  @spec put_changed_object(__MODULE__.t(), object_struct) :: __MODULE__.t()
  def put_changed_object(
        %__MODULE__{} = ctx,
        %{
          position: %{} = position,
          id: id,
          __struct__: struct
        } = o
      ) do
    key = Map.fetch!(@object_struct_map, struct)
    old = ctx |> Map.fetch!(key) |> Map.get(id)

    %{x: x, y: y} = Position.normalize(position)

    {{old_x, old_y}, action} =
      if old, do: {{old.position.x, old.position.y}, :update}, else: {{x, y}, :create}

    %{objects: objects} = ctx = Callback.handle(%Callback{action: action}, o, ctx)
    # IO.puts("#{action} #{ctx.slug} #{key} #{id} {#{x}, #{y}}")

    fingerprint = Object.fingerprint(o)
    new_o = objects |> Map.fetch!({x, y}) |> MapSet.put(fingerprint)

    diff =
      if {old_x, old_y} == {x, y} do
        %{{x, y} => new_o}
      else
        %{x: old_x, y: old_y} = old.position
        old_o = objects |> Map.fetch!({old_x, old_y}) |> MapSet.delete(fingerprint)
        %{{x, y} => new_o, {old_x, old_y} => old_o}
      end

    Map.merge(ctx, %{
      key => ctx |> Map.fetch!(key) |> Map.put(id, o),
      :objects => Map.merge(objects, diff)
    })
  end

  def fetch_object(ctx, :t, id), do: fetch_object(ctx, :tanks, id)
  def fetch_object(ctx, :p, id), do: fetch_object(ctx, :power_ups, id)
  def fetch_object(ctx, :b, id), do: fetch_object(ctx, :bullets, id)

  def fetch_object(ctx, key, id) do
    ctx |> Map.fetch!(key) |> Map.get(id)
  end

  def fetch_object!(ctx, key, id) do
    fetch_object(ctx, key, id) || raise("Can't find: #{key}, #{id}")
  end

  @spec update_object_raw(
          __MODULE__.t(),
          BattleCity.object_keys(),
          BattleCity.id(),
          (object_struct -> {object_struct, object_struct})
        ) :: __MODULE__.t()
  def update_object_raw(ctx, key, id, f) do
    ctx
    |> Map.fetch!(key)
    |> Map.get_and_update(id, f)
    |> case do
      {nil, _} -> ctx
      {_, data} -> Map.put(ctx, key, data)
    end
  end

  @spec update_object_raw!(
          __MODULE__.t(),
          BattleCity.object_keys(),
          BattleCity.id(),
          (object_struct -> {object_struct, object_struct})
        ) :: __MODULE__.t()
  def update_object_raw!(ctx, key, id, f) do
    {_, data} = ctx |> Map.fetch!(key) |> Map.get_and_update!(id, f)
    Map.put(ctx, key, data)
  end

  @spec delete_object(__MODULE__.t(), BattleCity.object_keys(), BattleCity.id()) :: __MODULE__.t()
  def delete_object(ctx, key, id) when key in @object_values do
    %{objects: objects} =
      ctx =
      Callback.handle(%Callback{action: :delete}, ctx |> Map.fetch!(key) |> Map.fetch!(id), ctx)

    data = ctx |> Map.fetch!(key)
    {o, data} = Map.pop!(data, id)
    xy = {o.position.x, o.position.y}
    # IO.puts("[delete] #{ctx.slug} #{key} #{id} #{inspect(xy)}, #{inspect(data)}")
    o = MapSet.delete(objects |> Map.fetch!(xy), Object.fingerprint(o))

    ctx |> Map.merge(%{key => data, :objects => Map.put(objects, xy, o)})
  end

  @spec handle_callbacks(__MODULE__.t()) :: __MODULE__.t()
  def handle_callbacks(%{__global_callbacks__: []} = ctx), do: ctx

  def handle_callbacks(%{__global_callbacks__: [f | rest]} = ctx) do
    ctx = f.(ctx)
    handle_callbacks(%{ctx | __global_callbacks__: rest})
  end
end
