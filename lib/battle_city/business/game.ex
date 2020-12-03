defmodule BattleCity.Business.Game do
  @moduledoc false

  alias BattleCity.Business.Core
  alias BattleCity.Context

  @spec next(Context.t()) :: Context.t()
  def next(%Context{} = ctx) do
    ctx |> Core.move_objects()
  end
end
