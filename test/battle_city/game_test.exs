defmodule BattleCity.GameTest do
  use ExUnit.Case, async: true

  # alias BattleCity.Process.GameDynamicSupervisor
  alias BattleCity.Context
  alias BattleCity.Event
  alias BattleCity.Game
  # alias BattleCity.Process.GameServer
  # alias BattleCity.Process.ProcessRegistry
  # alias BattleCity.Process.TankDynamicSupervisor

  @moduletag :game

  setup_all do
    _ = BattleCity.Process.StageCache.start_link([])
    []
  end

  test "pause", %{} do
    slug = "foo"
    name = "bar"
    {_pid, ctx} = Game.start_server(slug, %{player_name: name, loop_interval: 100})
    assert ctx.slug == slug
    assert ctx.state == :started
    assert Context.fetch_object!(ctx, :t, name).id == name

    position1 = Context.fetch_object!(ctx, :t, name).position

    ctx0 = Game.start_event(slug, %Event{name: :move, value: :up, id: name})
    Process.sleep(ctx.loop_interval)
    {_pid, ctx1} = Game.ctx(slug)
    position2 = Context.fetch_object!(ctx1, :t, name).position
    assert ctx1.counter == ctx0.counter + 1
    assert position2 != position1

    _ = Game.start_event(slug, %Event{name: :toggle_pause, value: nil, id: name})
    ctx2 = Game.start_event(slug, %Event{name: :move, value: :up, id: name})
    Process.sleep(ctx2.loop_interval)
    assert ctx1.counter == ctx2.counter
    assert ctx2.state == :paused
    assert position2 == Context.fetch_object!(ctx2, :t, name).position

    ctx3 = Game.start_event(slug, %Event{name: :toggle_pause, value: nil, id: name})
    Process.sleep(ctx3.loop_interval)
    {_pid, ctx3} = Game.ctx(slug)
    assert ctx3.state == :started
    assert ctx3.counter == ctx2.counter + 1
    # ctx = Game.start_event(slug, %Event{name: :toggle_pause, value: nil, id: name})
  end

  # test "kill server", %{} do
  #   bob_pid = GameDynamicSupervisor.server_process("bob")
  # end

  # test "operations", %{} do
  #   foo_pid = GameSupervisor.server_process("foo")
  #   Process.exit(foo_pid, :kill)
  #   ctx = "foo" |> GameSupervisor.server_process() |> GameServer.ctx()
  #   assert ctx.slug == "foo"
  # end
end
