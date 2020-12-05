defmodule BattleCity.ProcessTest do
  use ExUnit.Case, async: true
  doctest BattleCity.Process.ProcessRegistry

  alias BattleCity.Process.GameServer
  alias BattleCity.Process.GameSupervisor
  alias BattleCity.Process.ProcessRegistry

  setup_all do
    []
  end

  test "server process", %{} do
    bob_pid = GameSupervisor.server_process("bob")
    alice_pid = GameSupervisor.server_process("alice")
    ctx = GameServer.ctx(bob_pid)
    assert bob_pid != alice_pid
    assert GameServer.pid("bob") == bob_pid
    assert ProcessRegistry.pid({GameServer, "bob"}) == bob_pid
    assert ctx.slug == "bob"
    assert bob_pid == GameSupervisor.server_process("bob")
  end

  # test "operations", %{} do
  #   foo_pid = GameSupervisor.server_process("foo")
  #   Process.exit(foo_pid, :kill)
  #   ctx = "foo" |> GameSupervisor.server_process() |> GameServer.ctx()
  #   assert ctx.slug == "foo"
  # end
end
