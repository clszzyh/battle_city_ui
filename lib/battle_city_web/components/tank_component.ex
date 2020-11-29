defmodule BattleCityWeb.Components.TankComponent do
  use Phoenix.LiveDashboard.Web, :live_component

  alias BattleCity.Context
  alias BattleCity.Display
  alias BattleCity.Process.GameServer
  # alias BattleCity.Tank

  @tank_prefix "TANK"

  @impl true
  def mount(socket) do
    {:ok, assign(socket, tank: nil)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="tabular-info">
        <table class="table table-hover tabular-info-table">
          <tbody>
            <%= for {k, v} <- @tank do %>
              <tr><td><%= k %></td><td><pre><%= v %></pre></td></tr>
            <% end %>
          </tbody>
        </table>

        <%= if @page.allow_destructive_actions do %>
          <div class="modal-footer">
            <button class="btn btn-danger" phx-target="<%= @myself %>" phx-click="kill">Kill process</button>
          </div>
        <% end %>
    </div>
    """
  end

  @impl true
  def update(%{id: @tank_prefix <> s, path: path, return_to: return_to, page: page}, socket) do
    [pid, id] = String.split(s, ";")
    pid = :erlang.list_to_pid(String.to_charlist(pid))
    ctx = GameServer.invoke_call(pid, :ctx)
    tank = Context.fetch_object!(ctx, :tanks, id)

    {:ok,
     assign(socket,
       tank: Display.columns(tank),
       pid: pid,
       path: path,
       page: page,
       return_to: return_to
     )}
  end
end
