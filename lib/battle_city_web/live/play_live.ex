defmodule BattleCityWeb.PlayLive do
  use BattleCityWeb, :live_view
  alias BattleCityWeb.Presence
  require Logger

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <div phx-hook="game" id="game">
        <canvas phx-update="ignore" id="canvas"> Canvas is not supported! </canvas>
      </div>
      <div class="buttons">
        <button phx-click="toggle_debug", value="<%= @debug %>">Debug: <%= @debug %></button>
        <button phx-click="toggle_simulate_latency", value="<%= @latency %>">Latency: <%= @latency %></button>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_, %{"username" => username, "slug" => slug}, socket) do
    Presence.track_slug(socket, slug, %{pid: self(), name: username})

    Presence.track_liveview(
      socket,
      %{slug: slug, pid: self(), name: username, id: socket.id}
    )

    {:ok, assign(socket, debug: false, latency: false)}
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

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: _diff}, socket) do
    Logger.debug("presence_diff #{inspect(self())}")
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
end
