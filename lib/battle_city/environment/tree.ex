defmodule BattleCity.Environment.Tree do
  @moduledoc false

  use BattleCity.Environment,
    health: 0,
    enter?: true

  @impl true
  def handle_enter(_, %{} = t) do
    {:ok, %{t | hiden?: true}}
  end

  @impl true
  def handle_leave(_, %{} = t) do
    {:ok, %{t | hiden?: false}}
  end
end
