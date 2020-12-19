defmodule BattleCityWeb.PlayLive do
  use BattleCityWeb, :live_view
  require Logger

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <div phx-hook="game" id="game">
        <canvas phx-update="ignore" id="canvas"> Canvas is not supported! </canvas>
      </div>
      <div class="buttons">
        <button phx-click="invoke", phx-value-k="toggle_debug" phx-value-v="<%= @debug %>">Debug: <%= @debug %></button>
        <button phx-click="invoke", phx-value-k="toggle_simulate_latency" phx-value-v="<%= @latency %>">Latency: <%= @latency %></button>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_, %{"username" => _username, "slug" => _slug}, socket) do
    {:ok, assign(socket, debug: false, latency: false)}
  end

  @impl true
  def handle_event("invoke", %{"k" => "toggle_debug", "v" => "true"}, socket) do
    {:noreply, socket |> assign(:debug, false) |> push_event(:toggle_debug, %{value: false})}
  end

  def handle_event("invoke", %{"k" => "toggle_debug", "v" => "false"}, socket) do
    {:noreply, socket |> assign(:debug, true) |> push_event(:toggle_debug, %{value: true})}
  end

  @latency 1000

  def handle_event("invoke", %{"k" => "toggle_simulate_latency", "v" => "false"}, socket) do
    {:noreply,
     socket
     |> assign(:latency, @latency)
     |> push_event(:toggle_simulate_latency, %{value: @latency})}
  end

  def handle_event("invoke", %{"k" => "toggle_simulate_latency"}, socket) do
    {:noreply,
     socket |> assign(:latency, false) |> push_event(:toggle_simulate_latency, %{value: false})}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: _diff}, socket) do
    Logger.debug("presence_diff #{inspect(self())} #{socket.assigns.slug}")
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
