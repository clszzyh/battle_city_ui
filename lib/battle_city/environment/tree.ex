defmodule BattleCity.Environment.Tree do
  @moduledoc false

  use BattleCity.Environment,
    health: 0,
    allow_pass_tank: true

  @impl true
  def handle_enter(_, %Tank{} = t) do
    %{t | hiden?: true}
  end

  @impl true
  def handle_leave(_, %Tank{} = t) do
    %{t | hiden?: false}
  end
end
