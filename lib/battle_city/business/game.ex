defmodule BattleCity.Business.Game do
  @moduledoc false

  alias BattleCity.Business.Move
  alias BattleCity.Business.Overlap
  alias BattleCity.Context

  @spec next(Context.t()) :: Context.t()
  def next(%Context{} = ctx) do
    ctx |> Move.move_all() |> Overlap.resolve()
  end
end
