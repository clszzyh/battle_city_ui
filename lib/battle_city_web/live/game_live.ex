defmodule BattleCityWeb.GameLive do
  use BattleCityWeb, :live_view
  alias BattleCity.Game
  alias BattleCityWeb.Presence
  require Logger

  @impl true
  def mount(_params, %{"username" => username, "slug" => slug}, socket) do
    Logger.debug("Mounting! #{slug}")

    _ =
      if connected?(socket) do
        {:ok, _} =
          Presence.track(self(), "slug:#{slug}", socket.id, %{pid: self(), name: username})

        Presence.track_liveview(socket, %{slug: slug, pid: self(), name: username})
      else
        Logger.debug("Mount without connected. #{slug}")
      end

    {_pid, ctx} = Game.start_server(slug, %{player_name: username})
    {:ok, assign(socket, ctx: ctx)}
  end

  # @impl true
  # def handle_event("window_key_event", "ArrowUp", socket) do
  #   {:noreply, assign(socket, :y_origin, socket.assigns.y_origin + 1)}
  # end
end
