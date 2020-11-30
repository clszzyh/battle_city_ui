defmodule BattleCity.Environment.Tree do
  @moduledoc false

  use BattleCity.Environment,
    allow_pass_bullet: true,
    allow_pass_tank: true,
    allow_destroy: false

  @impl true
  def handle_on(_, %Tank{} = t) do
    %{t | hiden?: true}
  end

  @impl true
  def handle_off(_, %Tank{} = t) do
    %{t | hiden?: false}
  end
end
