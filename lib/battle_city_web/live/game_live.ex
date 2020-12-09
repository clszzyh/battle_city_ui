defmodule BattleCityWeb.GameLive do
  use BattleCityWeb, :live_view
  alias BattleCity.Game
  alias BattleCity.Position
  alias BattleCityWeb.Presence
  require Logger

  @impl true
  def mount(_params, %{"username" => username, "slug" => slug}, socket) do
    _ =
      if connected?(socket) do
        peer_data =
          if info = get_connect_info(socket) do
            info.peer_data |> Map.merge(%{user_agent: info.user_agent})
          else
            %{address: nil, port: nil, ssl_cert: nil, user_agent: nil}
          end

        connect_params = get_connect_params(socket)

        Logger.debug(
          "Mount and connected. #{slug} #{inspect(peer_data)}, #{inspect(connect_params)}"
        )

        Presence.track_slug(socket, slug, %{pid: self(), name: username})

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

    {:ok,
     assign(socket,
       ctx: ctx,
       quadrant_size: Position.real_quadrant(),
       grid: [
         {0, 0, 1.9, 1.9, "#FFFFFF"},
         {1, 2, 1.9, 1.9, "#EEEEEE"},
         {0, 12, 1.9, 1.9, "#111111"},
         {24, 24, 1.9, 1.9, "#222222"}
       ]
     )}
  end

  @impl true
  def handle_event("keydown", %{"key" => key}, socket) do
    Logger.debug("keydown unknown #{key}")
    {:noreply, socket}
  end

  def handle_event("keyup", %{"key" => key}, socket) do
    Logger.debug("keyup unknown #{key}")
    {:noreply, socket}
  end

  def handle_event(event, name, socket) do
    Logger.debug("event #{inspect(self())} #{inspect(event)} #{inspect(name)}")
    {:noreply, put_flash(socket, :info, inspect({event, name}))}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    Logger.debug("presence_diff #{inspect(self())} #{inspect(diff)}")
    {:noreply, socket}
  end

  def handle_info(name, socket) do
    Logger.debug("info #{inspect(self())} #{inspect(name)}")
    {:noreply, put_flash(socket, :info, inspect(name))}
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
