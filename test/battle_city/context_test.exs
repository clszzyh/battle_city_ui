defmodule BattleCity.ContextTest do
  use ExUnit.Case, async: true
  doctest BattleCity.Position

  alias BattleCity.Business.Generate
  alias BattleCity.Business.Move
  alias BattleCity.Context
  alias BattleCity.Position
  alias BattleCity.Stage

  setup_all do
    ctx = Context.init(Stage.S1)
    player = ctx.tanks |> Map.values() |> Enum.find(&match?(%{enemy?: false}, &1))
    [ctx: ctx, player: player, map: ctx.stage.map]
  end

  test "context init", %{ctx: ctx, player: player} do
    assert Enum.count(ctx.objects) == (Position.size() + 1) * (Position.size() + 1)
    assert player.position.x == 8
    assert player.position.y == 24
    assert player.position.rx == 9 * 8
    assert player.position.ry == 24 * 8
    assert player.position.direction == :up
    assert player.speed == 2
    assert player.health == 1
    assert player.changed? == false
    assert map_size(ctx.tanks) > 1
  end

  test "Put tank", %{ctx: ctx} do
    new_ctx = Generate.add_bot(ctx, %{bot_count: 1})
    assert Enum.count(new_ctx.tanks) == Enum.count(ctx.tanks) + 1
  end

  test "Put power up", %{ctx: ctx} do
    new_ctx = Generate.add_power_up(ctx, %{})
    assert Enum.count(new_ctx.power_ups) == Enum.count(ctx.power_ups) + 1
  end

  test "move_slow", %{player: %{position: position} = player, map: map} do
    player = %{player | moving?: true, speed: 4}
    new_player = Move.move(player, map)

    assert new_player.position.rt == position.ry - 4
    assert new_player.position.t == position.y
    assert new_player.position.path == []
    assert new_player.changed? == true

    assert new_player.position.x == position.x
    assert new_player.position.y == position.y
  end

  test "move_fast", %{player: %{position: position} = player, map: map} do
    player = %{player | moving?: true, speed: 14}
    new_player = Move.move(player, map)

    assert new_player.position.rt == position.ry - 14
    assert new_player.position.t == position.y - 2
    assert new_player.position.path == []
    assert new_player.changed? == true

    assert new_player.position.x == position.x
    assert new_player.position.y == position.y - 2
  end
end
