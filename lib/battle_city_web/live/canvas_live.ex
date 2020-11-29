defmodule BattleCityWeb.CanvasLive do
  use BattleCityWeb, :live_view

  @particles 250
  @da -0.005
  @ax 0
  @ay 0.00025

  def render(assigns) do
    ~L"""
    <div>
      <div phx-hook="canvas" id="canvas" data-particles="<%= Jason.encode!(@particles) %>">
        <canvas phx-update="ignore"> Canvas is not supported! </canvas>
      </div>
      <div class="buttons">
        <button phx-click="updates_per_second" value="32">30 updates per second</button>
        <button phx-click="updates_per_second" value="16">60 updates per second</button>
        <button phx-click="updates_per_second" value="8">120 updates per second</button>
      </div>
    </div>
    """
  end

  def mount(_, _, socket) do
    particles = for _ <- 1..@particles, do: create_particle()
    Process.send_after(self(), :update, 16)

    {:ok, socket |> assign(particles: particles, tick: 16)}
  end

  def handle_event("updates_per_second", %{"value" => value}, socket) do
    {tick, ""} = Integer.parse(value)
    {:noreply, assign(socket, :tick, tick)}
  end

  def handle_info(:update, %{assigns: %{particles: particles, tick: tick}} = socket) do
    Process.send_after(self(), :update, tick)
    {:noreply, assign(socket, :particles, Enum.map(particles, &update_particle/1))}
  end

  defp create_particle do
    [
      # a
      :rand.uniform(),
      # x
      0.0,
      # y
      0.0,
      # vx
      (:rand.uniform() - 0.5) / 20,
      # vy
      (:rand.uniform() - 0.5) / 20
    ]
  end

  defp update_particle([a, x, y, vx, vy]) do
    if a + @da < 0 do
      create_particle()
    else
      [
        a + @da,
        x + vx,
        y + vy,
        vx + @ax,
        vy + @ay
      ]
    end
  end
end
