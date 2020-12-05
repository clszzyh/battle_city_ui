defmodule BattleCity.ProcessTest do
  use ExUnit.Case, async: true
  doctest BattleCity.Process.ProcessRegistry

  alias BattleCity.Process.GameSupervisor

  test "server process" do
    bob_pid = GameSupervisor.server_process("bob")

    assert bob_pid != GameSupervisor.server_process("alice")
    assert bob_pid == GameSupervisor.server_process("bob")
  end
end
