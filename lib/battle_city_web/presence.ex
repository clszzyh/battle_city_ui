defmodule BattleCityWeb.Presence do
  use Phoenix.Presence,
    otp_app: :battle_city,
    pubsub_server: BattleCity.PubSub

  alias BattleCityWeb.Endpoint

  @liveview "liveview"
  @slug_prefix "slug:"

  @endpoint_slug_prefix "endpoint:"
  @endpoint "endpoint"

  @ctx_event "ctx"

  def broadcast_ctx(slug, ctx) do
    broadcast_slug(slug, @ctx_event, ctx)
  end

  def broadcast_endpoint(message, payload) do
    # Endpoint.broadcast_from(self(), @endpoint, message, payload)
    Endpoint.broadcast(@endpoint, message, payload)
  end

  def broadcast_slug(slug, message, payload) do
    # Endpoint.broadcast_from(self(), @endpoint_slug_prefix <> slug, message, payload)
    Endpoint.broadcast(@endpoint_slug_prefix <> slug, message, payload)
  end

  def track_liveview(socket, meta) do
    _ = Endpoint.subscribe(@endpoint)
    _ = Phoenix.PubSub.subscribe(BattleCity.PubSub, @liveview)
    _ = track(self(), @liveview, socket.id, meta)
    :ok
  end

  def track_slug(socket, slug, meta) do
    _ = Endpoint.subscribe(@endpoint_slug_prefix <> slug)
    _ = track(self(), @slug_prefix <> slug, socket.id, meta)
    :ok
  end

  def list_liveview do
    for {id, %{metas: [meta]}} <- list(@liveview) do
      Map.put(meta, :id, id)
    end
  end
end
