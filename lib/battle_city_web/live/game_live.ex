defmodule BattleCityWeb.GameLive do
  use BattleCityWeb, :live_view
  alias BattleCity.Game
  alias BattleCityWeb.Presence
  require Logger

  @impl true
  def mount(_params, %{"username" => username, "slug" => slug}, socket) do
    _ =
      if connected?(socket) do
        {:ok, _} =
          Presence.track(self(), "slug:#{slug}", socket.id, %{pid: self(), name: username})

        peer_data =
          if info = get_connect_info(socket) do
            info.peer_data
          else
            %{address: nil, port: nil, ssl_cert: nil}
          end

        connect_params = get_connect_params(socket)

        Logger.debug(
          "Mount and connected. #{slug} #{inspect(peer_data)}, #{inspect(connect_params)}"
        )

        Presence.track_liveview(
          socket,
          %{slug: slug, pid: self(), name: username, id: socket.id}
          |> Map.merge(peer_data)
          |> Map.merge(connect_params)
        )
      else
        Logger.debug("Mount without connected. #{slug}")
      end

    {_pid, ctx} = Game.start_server(slug, %{player_name: username})
    {:ok, assign(socket, ctx: ctx)}
  end

  @impl true
  def terminate(reason, _socket) do
    Logger.debug("terminate: #{inspect(self())} #{inspect(reason)}")
  end

  # @impl true
  # def handle_event("window_key_event", "ArrowUp", socket) do
  #   {:noreply, assign(socket, :y_origin, socket.assigns.y_origin + 1)}
  # end
end
