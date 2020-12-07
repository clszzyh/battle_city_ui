defmodule BattleCity.ProcessTest do
  use ExUnit.Case, async: true
  doctest BattleCity.Process.ProcessRegistry

  alias BattleCity.Process.GameDynamicSupervisor
  alias BattleCity.Process.GameServer
  alias BattleCity.Process.ProcessRegistry

  setup_all do
    _ = BattleCity.Process.StageCache.start_link([])
    []
  end

  test "server process", %{} do
    bob_pid = GameDynamicSupervisor.server_process("bob")
    alice_pid = GameDynamicSupervisor.server_process("alice")
    assert bob_pid != alice_pid
    bob_srv = GameServer.pid("bob")
    ctx = GameServer.ctx(bob_srv)
    assert bob_srv != bob_pid
    assert ProcessRegistry.pid({GameServer, "bob"}) == bob_srv
    assert ctx.slug == "bob"
    assert bob_pid == GameDynamicSupervisor.server_process("bob")
  end

  # test "operations", %{} do
  #   foo_pid = GameSupervisor.server_process("foo")
  #   Process.exit(foo_pid, :kill)
  #   ctx = "foo" |> GameSupervisor.server_process() |> GameServer.ctx()
  #   assert ctx.slug == "foo"
  # end
end
