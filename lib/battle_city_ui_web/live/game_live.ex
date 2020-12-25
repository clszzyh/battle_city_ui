defmodule BattleCityUiWeb.GameLive do
  use BattleCityUiWeb, :live_view

  alias BattleCity.Context
  alias BattleCity.Event
  alias BattleCity.Game

  @impl true
  def render(assigns) do
    ~L"""
    <div phx-hook="game" id="game"
      phx-window-keydown="keydown"
      data-size=20
      data-slug="<%= @slug %>"
      data-tank_grids="<%= Jason.encode!(@tank_grids) %>"
      data-bullet_grids="<%= Jason.encode!(@bullet_grids) %>"
      data-map_grids="<%= Jason.encode!(@map_grids) %>"
    >
      <canvas style="margin: 0 auto;" phx-update="ignore" id="canvas"> Canvas is not supported! </canvas>
      <div style="display: none">
        <%= for "assets/static/audio/" <> name <- Path.wildcard("assets/static/audio/*.{mp3,ogg}") do %>
          <audio
            id="<%= name |> String.split(".") |> List.first %>"
            src="<%= Routes.static_url(BattleCityUiWeb.Endpoint, "/audio/#{name}") %>"></audio>
        <% end %>
        <img id="sprites" src="<%= Routes.static_url(BattleCityUiWeb.Endpoint, "/images/sprites.png") %>"/>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_, %{"username" => username, "slug" => slug}, socket) do
    if connected?(socket) do
      Presence.track_slug(socket, slug, %{pid: self(), name: username})
      Presence.track_liveview(socket, %{slug: slug, pid: self(), name: username, id: socket.id})
    else
      Logger.debug("Mount without connected. #{slug}")
    end

    {_pid, ctx} = Game.start_server(slug, %{player_name: username, stage: 1, loop_interval: 100})

    Game.invoke_call(slug, :pause)

    {:ok,
     assign(socket,
       page_title: "BattleCity",
       slug: slug,
       username: username,
       debug: false,
       latency: false
     )
     |> tick(ctx)}
  end

  @handle_down_map %{
    {"keydown", "ArrowUp"} => {:move, :up},
    {"keydown", "ArrowDown"} => {:move, :down},
    {"keydown", "ArrowLeft"} => {:move, :left},
    {"keydown", "ArrowRight"} => {:move, :right},
    {"keydown", "w"} => {:move, :up},
    {"keydown", "s"} => {:move, :down},
    {"keydown", "a"} => {:move, :left},
    {"keydown", "d"} => {:move, :right},
    {"keydown", "Enter"} => {:toggle_pause, nil},
    {"keydown", "j"} => {:shoot, nil}
  }
  @handle_down_keys Map.keys(@handle_down_map)

  @impl true
  def handle_event(key_type, %{"key" => key}, %{assigns: %{username: name, ctx: ctx}} = socket)
      when {key_type, key} in @handle_down_keys do
    {event_name, value} = Map.fetch!(@handle_down_map, {key_type, key})
    {_, ctx} = Game.start_event(ctx, %Event{name: event_name, value: value, id: name})
    {:noreply, tick(socket, ctx)}
  end

  def handle_event("keydown", %{"key" => "D"}, %{assigns: %{debug: debug}} = socket) do
    debug = !debug

    {:noreply,
     socket
     |> assign(:debug, debug)
     |> put_flash(:info, "Debug: #{debug}")
     |> push_event(:toggle_debug, %{value: debug})}
  end

  @latency 1000

  def handle_event("keydown", %{"key" => "S"}, %{assigns: %{latency: latency}} = socket) do
    latency = if latency, do: false, else: @latency

    {:noreply,
     socket
     |> assign(:latency, latency)
     |> put_flash(:info, "Simulate Latency: #{latency}")
     |> push_event(:toggle_simulate_latency, %{value: latency})}
  end

  def handle_event("keydown", %{"key" => "-"}, %{assigns: assigns} = socket) do
    {_, ctx} = Game.invoke_call(assigns.slug, {"reset", %{stage: assigns.level - 1}})
    {:noreply, tick(socket, ctx)}
  end

  def handle_event("keydown", %{"key" => "+"}, %{assigns: assigns} = socket) do
    {_, ctx} = Game.invoke_call(assigns.slug, {"reset", %{stage: assigns.level + 1}})
    {:noreply, tick(socket, ctx)}
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    Logger.debug("#{socket.assigns.slug} keydown #{key}")
    {:noreply, socket}
  end

  def handle_event("invoke_call", %{"k" => name, "v" => value}, socket) do
    {_, ctx} = Game.invoke_call(socket.assigns.slug, {name, value})
    {:noreply, tick(socket, ctx)}
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff", payload: diff}, socket) do
    Logger.debug("presence_diff #{inspect(self())} #{inspect(diff)}")
    {:noreply, socket}
  end

  def handle_info(%Broadcast{event: "ctx", payload: ctx}, socket) do
    {:noreply, tick(socket, ctx)}
  end

  def handle_info(%Broadcast{event: "play_audio", payload: id}, socket) do
    {:noreply, socket |> push_event(:play_audio, %{id: id})}
  end

  def handle_info(name, socket) do
    Logger.debug("info #{inspect(self())} #{inspect(name)}")
    {:noreply, put_flash(socket, :info, inspect(name))}
  end

  @impl true
  def terminate(reason, socket) do
    _ = Game.pause(socket.assigns.slug)
    Logger.debug("terminate: #{inspect(self())} #{inspect(reason)}")
  end

  defp tick(socket, ctx) do
    tank_grids = Context.tank_grids(ctx)
    bullet_grids = Context.bullet_grids(ctx)
    map_grids = Context.map_grids(ctx)
    # Logger.debug(inspect(grids, limit: :infinity, pretty: true))
    if tank_grids == socket.assigns[:tank_grids] and
         bullet_grids == socket.assigns[:bullet_grids] and
         map_grids == socket.assigns[:map_grids] do
      socket |> assign(ctx: ctx)
    else
      socket
      |> assign(
        ctx: ctx,
        level: ctx.level,
        map_grids: map_grids,
        bullet_grids: bullet_grids,
        tank_grids: tank_grids
      )
      |> push_event(:tick, %{value: ctx.__counters__})
    end
  end
end
