defmodule BattleCityWeb.Components.ContextComponent do
  use Phoenix.LiveDashboard.Web, :live_component

  alias BattleCity.Process.GameServer

  @context_prefix "CONTEXT"
  @stage_prefix "STAGE"

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :stage, nil)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="tabular-info">
        <table class="table table-hover tabular-info-table">
          <tbody>
            <tr><td class="border-top-0">rest_enemies</td><td class="border-top-0"><pre><%= @ctx.rest_enemies %></pre></td></tr>
            <tr><td>shovel?</td><td><pre><%= @ctx.shovel? %></pre></td></tr>
            <tr><td>state</td><td><pre><%= @ctx.state %></pre></td></tr>
            <tr><td>loop_interval</td><td><pre><%= @ctx.loop_interval %></pre></td></tr>
            <tr><td>stage</td><td><pre><%= @stage_key %></pre></td></tr>
            <tr><td>objects</td><td><pre><%= @ctx.objects |> Map.values() |> Enum.map(&MapSet.size/1) |> Enum.sum %></pre></td></tr>
            <tr><td>power_ups</td><td><pre><%= Enum.count @ctx.power_ups %></pre></td></tr>
            <tr><td>tanks</td><td><pre><%= Enum.count @ctx.tanks %></pre></td></tr>
            <tr><td>bullets</td><td><pre><%= Enum.count @ctx.bullets %></pre></td></tr>
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
       ctx: ctx,
       stage_key: live_patch(ctx.stage.name, to: path.(node(pid), info: @stage_prefix <> pids)),
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
