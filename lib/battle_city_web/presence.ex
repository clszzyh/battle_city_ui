defmodule BattleCityWeb.Presence do
  use Phoenix.Presence,
    otp_app: :battle_city,
    pubsub_server: BattleCity.PubSub

  @liveview "liveview"

  def track_liveview(socket, meta) do
    track(self(), @liveview, socket.id, meta)
  end

  def list_liveview do
    for {key, %{metas: [meta]}} <- list(@liveview) do
      Map.put(meta, :key, key)
    end
  end
end
