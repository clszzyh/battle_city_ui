defmodule BattleCityUi.GameHandler do
  @moduledoc false

  use BattleCity.GameCallback

  alias BattleCityUiWeb.Presence

  @impl true
  def handle_tick(ctx) do
    :ok = Presence.broadcast_slug(ctx.slug, "ctx", ctx)
    ctx
  end

  @impl true
  def handle_event(ctx, id) do
    :ok = Presence.broadcast_slug(ctx.slug, "play_audio", id)
    ctx
  end
end
