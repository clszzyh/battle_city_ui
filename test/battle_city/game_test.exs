defmodule BattleCity.GameTest do
  use ExUnit.Case, async: true

  # alias BattleCity.Process.GameDynamicSupervisor
  alias BattleCity.Context
  alias BattleCity.Event
  alias BattleCity.Game
  # alias BattleCity.Position
  # alias BattleCity.Process.GameServer
  # alias BattleCity.Process.ProcessRegistry
  # alias BattleCity.Process.TankDynamicSupervisor

  @moduletag :game

  setup_all do
    _ = BattleCity.Process.StageCache.start_link([])
    []
  end

  test "left bullet", %{} do
    slug = "left bullet"
    name = "bar"
    {_pid, _ctx} = Game.start_server(slug, %{player_name: name, mock: true})
    _ = Game.start_event(slug, %Event{name: :move, value: :left, id: name})
    _ = Game.start_event(slug, %Event{name: :shoot, value: nil, id: name})
    {_pid, ctx} = Game.ctx(slug)
    grids = Context.object_grids(ctx)
    assert Enum.count(grids) == 5 + 1
    assert Enum.count(ctx.bullets) == 1
    # ctx = Game.loop(slug)
    ctx = Game.loop(slug, 100)
    # {_pid, ctx} = Game.ctx(slug)
    assert Enum.empty?(ctx.bullets)
    grids = Context.object_grids(ctx)
    assert Enum.count(grids) == 5
  end

  test "pause and move", %{} do
    slug = "foo"
    name = "bar"
    {_pid, ctx} = Game.start_server(slug, %{player_name: name, mock: true})
    assert ctx.slug == slug
    assert ctx.state == :started
    assert Context.fetch_object!(ctx, :t, name).id == name

    position1 = Context.fetch_object!(ctx, :t, name).position

    ctx0 = Game.start_event(slug, %Event{name: :move, value: :up, id: name})
    ctx1 = Game.loop(slug)
    position2 = Context.fetch_object!(ctx1, :t, name).position
    assert ctx1.counter == ctx0.counter + 1
    assert position2 != position1

    _ = Game.start_event(slug, %Event{name: :toggle_pause, value: nil, id: name})
    _ctx2 = Game.start_event(slug, %Event{name: :move, value: :up, id: name})
    ctx2 = Game.loop(slug)
    assert ctx1.counter + 1 == ctx2.counter
    assert ctx2.state == :paused
    assert position2 == Context.fetch_object!(ctx2, :t, name).position

    _ctx3 = Game.start_event(slug, %Event{name: :toggle_pause, value: nil, id: name})
    ctx3 = Game.loop(slug)
    assert ctx3.state == :started
    assert ctx3.counter == ctx2.counter + 1
    # ctx = Game.start_event(slug, %Event{name: :toggle_pause, value: nil, id: name})
  end

  test "shoot", %{} do
    slug = "a"
    name = "b"
    {_pid, ctx} = Game.start_server(slug, %{player_name: name, mock: true})
    tank = ctx |> Context.fetch_object!(:tanks, name)
    position = tank.position
    x = position.x
    y = position.y
    assert Map.fetch!(ctx.objects, {x, y}) == MapSet.new([{:t, name, false}])
    ctx = Game.start_event(slug, %Event{name: :shoot, id: name, value: nil})
    assert Map.fetch!(ctx.objects, {x, y}) == MapSet.new([{:t, name, false}, {:b, "b0", false}])
    assert Enum.count(ctx.bullets) == 1
    bullet = Map.fetch!(ctx.bullets, "b0")
    assert bullet.position.ry == position.ry
    assert position.direction == :up
    ctx1 = Game.loop(slug)
    assert ctx1.counter == ctx.counter + 1
    new_bullet = Map.fetch!(ctx1.bullets, "b0")
    new_position = new_bullet.position
    assert new_position.ry == position.ry - new_bullet.speed
    # assert new_position.width == 0.1 * Position.atom() * Position.width()
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
