defmodule BattleCity.Environment.Ice do
  @moduledoc false

  use BattleCity.Environment,
    allow_pass_bullet: true,
    allow_pass_tank: true,
    allow_destroy: false

  @impl true
  def on(%Tank{tank: %{move_speed: move_speed} = tank} = t) do
    %{t | tank: %{tank | move_speed: move_speed + 10}}
  end

  @impl true
  def off(%Tank{tank: %{move_speed: move_speed} = tank} = t) do
    %{t | tank: %{tank | move_speed: move_speed - 10}}
  end
end
