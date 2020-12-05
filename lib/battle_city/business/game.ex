defmodule BattleCity.Business.Game do
  @moduledoc false

  alias BattleCity.Business.Location
  alias BattleCity.Business.Overlap
  alias BattleCity.Context
  alias BattleCity.Event
  require Logger

  @spec loop(Context.t()) :: Context.t()
  def loop(%Context{} = ctx) do
    Logger.debug("[Loop] #{ctx.slug}")
    ctx |> Location.move_all() |> Overlap.resolve()
  end

  @spec handle_event(Context.t(), Event.t()) :: Context.t()
  def handle_event(%Context{} = ctx, %Event{}) do
    Logger.debug("[Event] #{ctx.slug}")
    ctx
  end
end
