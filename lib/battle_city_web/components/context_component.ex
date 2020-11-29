defmodule BattleCityWeb.Components.ContextComponent do
  use Phoenix.LiveDashboard.Web, :live_component

  alias BattleCity.Display
  alias BattleCity.Process.GameServer

  @context_prefix "CONTEXT"
  @stage_prefix "STAGE"
  @tank_prefix "TANK"

  @impl true
  def mount(socket) do
    {:ok, assign(socket, ctx: nil, stage: nil)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="tabular-info">
        <table class="table table-hover tabular-info-table">
          <tbody>
            <%= for {k, v} <- @ctx do %>
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
  def update(%{id: @context_prefix <> pids, path: path, return_to: return_to, page: page}, socket) do
    pid = :erlang.list_to_pid(String.to_charlist(pids))
    ctx = GameServer.invoke_call(pid, :ctx)
    stage_fn = fn n -> live_patch(n, to: path.(node(pid), info: @stage_prefix <> pids)) end

    tank_fn = fn n, id ->
      live_patch(n, to: path.(node(pid), info: "#{@tank_prefix}#{pids};#{id}"))
    end

    {:ok,
     assign(socket,
       ctx: Display.columns(ctx, stage_fn: stage_fn, tank_fn: tank_fn),
       pid: pid,
       path: path,
       page: page,
       return_to: return_to
     )}
  end

  @impl true
  def handle_event("kill", _, socket) do
    true = socket.assigns.page.allow_destructive_actions
    Process.exit(socket.assigns.pid, :kill)
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
