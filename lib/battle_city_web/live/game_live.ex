defmodule BattleCityWeb.GameLive do
  use BattleCityWeb, :live_view
  alias BattleCity.Game
  alias BattleCityWeb.Presence
  require Logger

  @impl true
  def mount(%{"slug" => slug}, session, socket) do
    inner_mount(slug, session, socket)
  end

  def mount(_params, session, socket) do
    inner_mount("unknown", session, socket)
  end

  defp inner_mount(slug, %{"username" => username}, socket) do
    Logger.debug("Mounting! #{slug}")

    topic = "slug:#{slug}"

    if connected?(socket) do
      {:ok, _} = Presence.track(self(), topic, socket.id, %{pid: self(), name: username})
      {:ok, _} = Presence.track_liveview(socket, %{slug: slug, pid: self(), name: username})
      Logger.debug("Connected. #{slug}")
    end

    ctx = Game.init(slug, %{player_name: username})
    {:ok, assign(socket, ctx: ctx)}
  end

  # @impl true
  # def handle_event("window_key_event", "ArrowUp", socket) do
  #   {:noreply, assign(socket, :y_origin, socket.assigns.y_origin + 1)}
  # end
end
