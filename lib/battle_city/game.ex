defmodule BattleCity.Game do
  @moduledoc false

  alias BattleCity.Business.Generate
  alias BattleCity.Business.Location
  alias BattleCity.Business.Overlap
  alias BattleCity.Context
  alias BattleCity.Event
  alias BattleCity.Process.GameDynamicSupervisor
  alias BattleCity.Process.GameServer
  alias BattleCity.Process.StageCache
  alias BattleCity.Tank
  alias BattleCity.Telemetry
  require Logger

  @default_stage 1

  @mock_range 0..2
  def mock do
    _ = BattleCity.Process.StageCache.start_link([])

    for i <- @mock_range, do: start_server("mock-#{i}", %{player_name: "player-#{i}"})
  end

  def start_server(slug, opts) do
    _pid = GameDynamicSupervisor.server_process(slug, opts)
    srv = GameServer.pid(slug)
    {srv, GameServer.ctx(srv)}
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

    %Context{slug: slug, stage: stage}
    |> Context.initial_objects()
    |> Context.put_object(player)
    |> Generate.add_bot(opts)
  end

  @spec loop(Context.t()) :: Context.t()
  def loop(%Context{} = ctx) do
    Telemetry.span(
      :game_loop,
      fn ->
        ctx = do_loop(ctx)
        {ctx, %{slug: ctx.slug}}
      end,
      %{slug: ctx.slug}
    )
  end

  @spec do_loop(Context.t()) :: Context.t()
  defp do_loop(%Context{} = ctx) do
    ctx |> Location.move_all() |> Overlap.resolve()
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
  def do_event(%Context{} = ctx, %Event{}) do
    ctx
  end
end
