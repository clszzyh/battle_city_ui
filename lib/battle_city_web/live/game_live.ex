defmodule BattleCityWeb.GameLive do
  use BattleCityWeb, :live_view
  alias BattleCity.Context
  alias BattleCity.Event
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
       slug: slug,
       quadrant_size: Position.real_quadrant()
     )}
  end

  defp grids(ctx), do: Context.grids(ctx)

  @handle_down_map %{
    {"keydown", "ArrowUp"} => {:move, :up},
    {"keydown", "ArrowDown"} => {:move, :down},
    {"keydown", "ArrowLeft"} => {:move, :left},
    {"keydown", "ArrowRight"} => {:move, :right},
    {"keydown", "Enter"} => {:toggle_pause, nil}
  }
  @handle_down_keys Map.keys(@handle_down_map)

  @impl true
  def handle_event(key_type, %{"key" => key}, %{assigns: %{ctx: ctx, slug: slug}} = socket)
      when {key_type, key} in @handle_down_keys do
    {name, value} = Map.fetch!(@handle_down_map, {key_type, key})
    _ = Game.start_event(slug, %Event{name: name, value: value})
    {:noreply, assign(socket, :ctx, ctx)}
  end

  def handle_event(event, name, socket) do
    Logger.debug("event #{inspect(self())} #{inspect(event)} #{inspect(name)} #{inspect(socket)}")
    # {:noreply, put_flash(socket, :info, inspect({event, name}))}
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    Logger.debug("presence_diff #{inspect(self())} #{inspect(diff)}")
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "ctx", payload: ctx}, socket) do
    # Logger.debug("ping")
    {:noreply, assign(socket, :ctx, ctx)}
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
