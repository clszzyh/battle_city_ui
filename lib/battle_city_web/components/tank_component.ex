defmodule BattleCityWeb.Components.TankComponent do
  use Phoenix.LiveDashboard.Web, :live_component

  alias BattleCity.Process.GameServer
  # alias BattleCity.Tank

  @tank_prefix "TANK"

  @impl true
  def mount(socket) do
    {:ok, assign(socket, ctx: nil, id: nil, type: nil)}
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
    </div>
    """
  end

  @impl true
  def update(%{id: @tank_prefix <> pid, path: path, return_to: return_to, page: page}, socket) do
    pid = :erlang.list_to_pid(String.to_charlist(pid))
    ctx = GameServer.ctx(pid)

    {:ok,
     assign(socket,
       ctx: ctx,
       pid: pid,
       path: path,
       page: page,
       return_to: return_to
     )}
  end
end
