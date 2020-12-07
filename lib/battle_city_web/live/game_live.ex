defmodule BattleCityWeb.GameLive do
  use BattleCityWeb, :live_view
  alias BattleCity.Game
  require Logger

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    inner_mount(slug, socket)
  end

  def mount(_params, _session, socket) do
    inner_mount("unknown", socket)
  end

  defp inner_mount(slug, socket) do
    Logger.debug("Mounting! #{slug}")

    topic = "slug:#{slug}"

    if connected?(socket) do
      {:ok, _} = BattleCity.Presence.track(self(), topic, socket.id, %{pid: self()})
      {:ok, _} = BattleCity.Presence.track_liveview(socket.id, slug)
      Logger.debug("Connected. #{slug}")
    end

    ctx = Game.init(slug)
    {:ok, assign(socket, ctx: ctx)}
  end

  # @impl true
  # def handle_event("window_key_event", "ArrowUp", socket) do
  #   {:noreply, assign(socket, :y_origin, socket.assigns.y_origin + 1)}
  # end
end
