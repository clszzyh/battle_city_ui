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
  def handle_event(ctx, :start) do
    :ok = Presence.broadcast_slug(ctx.slug, "play_audio", "start")
    ctx
  end

  def handle_event(ctx, :pause) do
    :ok = Presence.broadcast_slug(ctx.slug, "play_audio", "pause")
    ctx
  end
end
