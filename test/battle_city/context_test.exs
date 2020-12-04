defmodule BattleCity.ContextTest do
  use ExUnit.Case, async: true

  alias BattleCity.Business.Generate
  alias BattleCity.Business.Move
  alias BattleCity.Context
  alias BattleCity.Position
  alias BattleCity.Stage

  setup_all do
    ctx = Context.init(Stage.S1)
    player = ctx.tanks |> Map.values() |> Enum.find(&match?(%{enemy?: false}, &1))
    [ctx: ctx, player: player]
  end

  test "context init", %{ctx: ctx} do
    assert Enum.count(ctx.objects) == (Position.size() + 1) * (Position.size() + 1)
  end

  test "Put tank", %{ctx: ctx} do
    new_ctx = Generate.add_bot(ctx, %{bot_count: 1})
    assert Enum.count(new_ctx.tanks) == Enum.count(ctx.tanks) + 1
  end

  test "Put power up", %{ctx: ctx} do
    new_ctx = Generate.add_power_up(ctx, %{})
    assert Enum.count(new_ctx.power_ups) == Enum.count(ctx.power_ups) + 1
  end

  test "move", %{ctx: ctx, player: player} do
    assert player.position.x == 8
    assert player.position.y == 24
    assert player.position.rx == 9 * 8
    assert player.position.ry == 24 * 8
    ctx = ctx |> Context.put_object(%{player | moving?: true})
    _ctx = ctx |> Move.move_all()
  end
end
