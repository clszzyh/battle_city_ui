defmodule BattleCity.Game do
  @moduledoc false

  alias BattleCity.Ai
  alias BattleCity.Business.Generate
  alias BattleCity.Business.Location
  alias BattleCity.Business.Overlap
  alias BattleCity.Context
  alias BattleCity.Event
  alias BattleCity.Process.GameDynamicSupervisor
  alias BattleCity.Process.GameServer
  alias BattleCity.Process.ProcessRegistry
  alias BattleCity.Process.StageCache
  alias BattleCity.Process.TankDynamicSupervisor
  alias BattleCity.Process.TankServer
  alias BattleCity.Tank
  alias BattleCity.Telemetry
  alias BattleCityWeb.Presence
  require Logger

  if Mix.env() == :dev do
    @default_stage 0
  else
    @default_stage 1
  end

  @mock_range 0..2
  @loop_interval 100
  @bot_loop_interval 100
  @timeout_interval 1000 * 60 * 60 * 24
  @ai BattleCity.Ai.Basic

  def mock do
    for i <- @mock_range, do: start_server("mock-#{i}", %{player_name: "player-#{i}"})
  end

  @spec ctx(BattleCity.slug()) :: {pid, Context.t()}
  def ctx(slug) do
    srv = GameServer.pid(slug)
    {srv, GameServer.invoke_call(srv, :ctx)}
  end

  def events(slug, id) do
    {_, ctx} = ctx(slug)
    for e <- ctx.__events__, e.id == id, do: e
  end

  @spec start_event(Context.t(), Event.t()) :: {atom(), Context.t()}
  def start_event(ctx, event) do
    invoke_call(ctx.slug, {:event, %{event | counter: ctx.__counters__.loop}})
  end

  def invoke_call(slug, opts) do
    srv = GameServer.pid(slug)
    GameServer.invoke_call(srv, opts)
  end

  def refresh_tank_process(slug) do
    tank_sup = TankDynamicSupervisor.pid(slug)
    childs = TankDynamicSupervisor.children(tank_sup)
    for %{pid: pid} <- childs, do: TankServer.refresh(pid)
    :ok
  end

  @spec loop_bot(Ai.t()) :: Ai.t()
  def loop_bot(%{slug: slug, id: id, move_event: move_event, shoot_event: shoot_event} = state) do
    {srv, ctx} = ctx(slug)
    tank = Context.fetch_object(ctx, :t, id)

    if is_nil(tank) do
      Logger.error("Not found: #{inspect(self())} #{slug} #{id}")
      state
    else
      new_move_event = Ai.shoot(ctx, tank, move_event)
      new_shoot_event = Ai.move(ctx, tank, shoot_event)

      for e <- [new_move_event, new_shoot_event],
          e != nil,
          do: GameServer.invoke_call(srv, {:event, e})

      %{
        state
        | pid: srv,
          loop: ctx.state == :started and ctx.enable_bot,
          move_event: new_move_event || move_event,
          shoot_event: new_shoot_event || shoot_event
      }
    end
  end

  @spec start_server(BattleCity.slug(), map()) :: {pid, Context.t()}
  def start_server(slug, opts) do
    _pid = GameDynamicSupervisor.server_process(slug, opts)
    ctx(slug)
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
    level = Map.get(opts, :stage, @default_stage)
    module = level |> StageCache.fetch_stage()
    stage = module.init(opts)
    tank = opts |> Map.get(:player_tank, Tank.Level1)

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
      mock: Map.get(opts, :mock, false),
      level: level,
      __opts__: opts,
      ai: Map.get(opts, :ai, @ai),
      enable_bot: Map.get(opts, :enable_bot, true),
      loop_interval: Map.get(opts, :loop_interval, @loop_interval),
      bot_loop_interval: Map.get(opts, :bot_loop_interval, @bot_loop_interval),
      timeout_interval: Map.get(opts, :timeout_interval, @timeout_interval)
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
        %{__counters__: %{loop: loop} = counter} = ctx = do_loop(ctx)
        {%{ctx | __counters__: %{counter | loop: loop + 1}}, %{slug: ctx.slug}}
      end,
      %{slug: ctx.slug}
    )
  end

  @spec do_loop(Context.t()) :: Context.t()
  defp do_loop(%Context{} = ctx) do
    ctx
    |> Location.move_all()
    |> Overlap.resolve()
    |> Generate.add_power_up()
    |> Context.handle_callbacks()
    |> broadcast()
  end

  @spec broadcast(Context.t()) :: Context.t()
  defp broadcast(%Context{} = ctx) do
    _ = Presence.broadcast_ctx(ctx.slug, Context.grids(ctx))
    ctx
  end

  def list do
    games = ProcessRegistry.search(GameServer)

    for %{name: slug} = i <- games do
      tank_sup = TankDynamicSupervisor.pid(slug)

      i
      |> Map.merge(%{tank_sup: tank_sup})
      |> Map.merge(DynamicSupervisor.count_children(tank_sup))
    end
  end
end
