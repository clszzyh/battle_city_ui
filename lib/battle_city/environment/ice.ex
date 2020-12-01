defmodule BattleCity.Environment.Ice do
  @moduledoc false

  use BattleCity.Environment,
    health: 0,
    enter?: false

  @impl true
  def handle_enter(_, %Tank{meta: %{move_speed: move_speed} = tank} = t) do
    %{t | meta: %{tank | move_speed: move_speed + 10}}
  end

  @impl true
  def handle_leave(_, %Tank{meta: %{move_speed: move_speed} = tank} = t) do
    %{t | meta: %{tank | move_speed: move_speed - 10}}
  end
end
