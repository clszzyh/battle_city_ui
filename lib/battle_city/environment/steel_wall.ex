defmodule BattleCity.Environment.SteelWall do
  @moduledoc false

  use BattleCity.Environment,
    health: 4,
    enter?: false

  # @impl true
  # def handle_init(%{stage: _stage} = o) do
  #   o
  # end
end
