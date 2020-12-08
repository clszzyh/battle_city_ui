defmodule BattleCityWeb.Presence do
  use Phoenix.Presence,
    otp_app: :battle_city,
    pubsub_server: BattleCity.PubSub

  @liveview "liveview"

  def track_liveview(socket, slug) do
    track(self(), @liveview, socket.id, %{slug: slug, pid: self()})
  end

  def list_liveview do
    for {key, %{metas: [%{phx_ref: ref, pid: pid, slug: slug}]}} <- list(@liveview) do
      %{key: key, ref: ref, pid: pid, slug: slug}
    end
  end
end
