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
        <button phx-click="updates_per_second" value="32">30 updates per second</button>
        <button phx-click="updates_per_second" value="16">60 updates per second</button>
        <button phx-click="updates_per_second" value="8">120 updates per second</button>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_, %{"username" => _username, "slug" => _slug}, socket) do
    {:ok, socket}
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
