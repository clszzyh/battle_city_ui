defmodule BattleCityWeb.GameLive do
  use BattleCityWeb, :live_view

  alias BattleCity.Context
  alias BattleCity.Game
  alias BattleCityWeb.Presence
  require Logger

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <div phx-hook="game" id="game">
        <canvas phx-update="ignore" id="canvas"> Canvas is not supported! </canvas>
      </div>
      <div style="display: none">
        <img id="sprites" src="<%= Routes.static_url(BattleCityWeb.Endpoint, "/images/sprites.png") %>" alt="sprites">
      </div>
    </div>
    """
  end

  #     <div class="buttons">
  # <button phx-click="toggle_debug", value="<%= @debug %>">Debug: <%= @debug %></button>
  # <button phx-click="toggle_simulate_latency", value="<%= @latency %>">Latency: <%= @latency %></button>
  #          </div>

  @impl true
  def mount(_, %{"username" => username, "slug" => slug}, socket) do
    Presence.track_slug(socket, slug, %{pid: self(), name: username})

    Presence.track_liveview(
      socket,
      %{slug: slug, pid: self(), name: username, id: socket.id}
    )

    {_pid, ctx} = Game.start_server(slug, %{player_name: username})

    {:ok,
     assign(socket, slug: slug, username: username, debug: false, latency: false)
     |> tick(Context.grids(ctx))}
  end

  @impl true
  def handle_event("toggle_debug", %{"value" => "true"}, socket) do
    {:noreply, socket |> assign(:debug, false) |> push_event(:toggle_debug, %{value: false})}
  end

  def handle_event("toggle_debug", %{"value" => "false"}, socket) do
    {:noreply, socket |> assign(:debug, true) |> push_event(:toggle_debug, %{value: true})}
  end

  @latency 1000

  def handle_event("toggle_simulate_latency", %{"value" => "false"}, socket) do
    {:noreply,
     socket
     |> assign(:latency, @latency)
     |> push_event(:toggle_simulate_latency, %{value: @latency})}
  end

  def handle_event("toggle_simulate_latency", %{}, socket) do
    {:noreply,
     socket |> assign(:latency, false) |> push_event(:toggle_simulate_latency, %{value: false})}
  end

  # def handle_event(key_type, v, socket) do
  #   {:noreply, put_flash(socket, :info, inspect({key_type, v}))}
  # end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: _diff}, socket) do
    Logger.debug("presence_diff #{inspect(self())}")
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "ctx", payload: grids}, socket) do
    {:noreply, tick(socket, grids)}
  end

  def handle_info(name, socket) do
    Logger.debug("info #{inspect(self())} #{inspect(name)}")
    {:noreply, put_flash(socket, :info, inspect(name))}
  end

  @impl true
  def terminate(reason, _socket) do
    Logger.debug("terminate: #{inspect(self())} #{inspect(reason)}")
  end

  defp tick(socket, grids) do
    push_event(socket, :tick, %{value: grids})
  end
end
