defmodule BattleCityWeb.Components.ContextComponent do
  use Phoenix.LiveDashboard.Web, :live_component

  alias BattleCity.Display
  alias BattleCity.Process.GameServer

  @context_prefix "CONTEXT"
  @stage_prefix "STAGE"

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
            <tr><td>stage</td><td><pre><%= @stage %></pre></td></tr>
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
    ctx = GameServer.ctx(pid)

    {:ok,
     assign(socket,
       ctx: Display.columns(ctx),
       stage: live_patch(ctx.stage.name, to: path.(node(pid), info: @stage_prefix <> pids)),
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
