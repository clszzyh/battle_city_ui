defmodule BattleCity.Game do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Business.Generate
  alias BattleCity.Business.Location
  alias BattleCity.Business.Overlap
  alias BattleCity.Context
  alias BattleCity.Event
  alias BattleCity.Position
  alias BattleCity.Process.GameDynamicSupervisor
  alias BattleCity.Process.GameServer
  alias BattleCity.Process.StageCache
  alias BattleCity.Tank
  alias BattleCity.Telemetry
  alias BattleCityWeb.Presence
  require Logger

  @default_stage 1
  @mock_range 0..2
  @loop_interval 100
  @timeout_interval 1000 * 60 * 60 * 24

  def mock do
    _ = BattleCity.Process.StageCache.start_link([])

    for i <- @mock_range, do: start_server("mock-#{i}", %{player_name: "player-#{i}"})
  end

  @spec ctx(BattleCity.slug()) :: {pid, Context.t()}
  def ctx(slug) do
    srv = GameServer.pid(slug)
    {srv, GameServer.ctx(srv)}
  end

  def loop(slug, times \\ 1) do
    srv = GameServer.pid(slug)
    GameServer.loop(srv, times)
  end

  @spec start_server(BattleCity.slug(), map()) :: {pid, Context.t()}
  def start_server(slug, opts) do
    _pid = GameDynamicSupervisor.server_process(slug, opts)
    ctx(slug)
  end

  @spec start_event(BattleCity.slug(), Event.t()) :: Context.t()
  def start_event(slug, event) do
    srv = GameServer.pid(slug)
    # Logger.info("[Event] #{slug} -> #{inspect(event)}")
    GameServer.event(srv, event)
  end

  @spec init(BattleCity.slug(), map()) :: Context.t()
  def init(slug, opts \\ %{}) do
    Telemetry.span(
      :game_init,
      fn ->
        ctx = do_init(slug, opts)
        {ctx, %{slug: ctx.slug}}
      end,
      %{slug: slug, opts: opts}
    )
  end

  @spec do_init(BattleCity.slug(), map()) :: Context.t()
  defp do_init(slug, opts) do
    module = opts |> Map.get(:stage, @default_stage) |> StageCache.fetch_stage()
    stage = module.init(opts)
    tank = opts |> Map.get(:player_tank, Tank.Level1)
    loop_interval = Map.get(opts, :loop_interval, @loop_interval)
    timeout_interval = Map.get(opts, :timeout_interval, @timeout_interval)
    mock = Map.get(opts, :mock, false)

    player =
      opts
      |> Map.merge(%{
        enemy?: false,
        x: :x_player_1,
        y: :y_player_1,
        direction: :up,
        id: opts[:player_name]
      })
      |> tank.new()

    %Context{
      slug: slug,
      stage: stage,
      mock: mock,
      loop_interval: loop_interval,
      timeout_interval: timeout_interval
    }
    |> Context.initial_objects()
    |> Context.put_object(player)
    |> Generate.add_bot(opts)
  end

  @spec loop_ctx(Context.t()) :: Context.t()
  def loop_ctx(%Context{} = ctx) do
    Telemetry.span(
      :game_loop,
      fn ->
        %{counter: counter} = ctx = do_loop(ctx)
        {%{ctx | counter: counter + 1}, %{slug: ctx.slug}}
      end,
      %{slug: ctx.slug}
    )
  end

  @spec do_loop(Context.t()) :: Context.t()
  defp do_loop(%Context{} = ctx) do
    ctx |> Location.move_all() |> Overlap.resolve() |> Generate.add_power_up() |> broadcast()
  end

  @spec broadcast(Context.t()) :: Context.t()
  defp broadcast(%Context{} = ctx) do
    _ = Presence.broadcast_ctx(ctx)
    ctx
  end

  @spec event(Context.t(), Event.t()) :: Context.t()
  def event(ctx, event) do
    Telemetry.span(
      :game_event,
      fn ->
        ctx = do_event(ctx, event)
        {ctx, %{slug: ctx.slug}}
      end,
      %{
        slug: ctx.slug,
        event_id: event.id
      }
    )
  end

  @spec do_event(Context.t(), Event.t()) :: Context.t()
  defp do_event(%Context{} = ctx, %Event{name: :move, value: direction, id: id}) do
    ctx |> Context.update_object_raw(:tanks, id, &move(&1, direction))
  end

  defp do_event(%Context{} = ctx, %Event{name: :shoot, id: id}) do
    tank = ctx |> Context.fetch_object!(:tanks, id)

    shoot(tank)
    |> case do
      :ignored ->
        ctx

      bullet ->
        ctx
        |> Context.update_object_raw(:tanks, id, fn t -> {t, %{t | shootable?: false}} end)
        |> Context.put_object(bullet)
    end
  end

  defp move(%Tank{position: p} = tank, direction) do
    {tank, %{tank | moving?: true, position: %{p | direction: direction}}}
  end

  @spec shoot(Tank.t()) :: :ignored | Bullet.t()
  defp shoot(%Tank{dead?: true}), do: :ignored
  defp shoot(%Tank{shootable?: false}), do: :ignored

  defp shoot(%Tank{id: tank_id, enemy?: enemy?, meta: %{bullet_speed: speed}, position: position}) do
    %Bullet{
      enemy?: enemy?,
      position: Position.bullet(position),
      tank_id: tank_id,
      speed: speed * Position.speed()
    }
  end
end
