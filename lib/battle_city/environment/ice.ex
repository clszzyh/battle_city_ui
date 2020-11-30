defmodule BattleCity.Environment.Ice do
  @moduledoc false

  use BattleCity.Environment,
    health: 0,
    allow_pass_tank: true

  @impl true
  def handle_enter(_, %Tank{tank: %{move_speed: move_speed} = tank} = t) do
    %{t | tank: %{tank | move_speed: move_speed + 10}}
  end

  @impl true
  def handle_leave(_, %Tank{tank: %{move_speed: move_speed} = tank} = t) do
    %{t | tank: %{tank | move_speed: move_speed - 10}}
  end
end
