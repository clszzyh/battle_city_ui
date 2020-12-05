defmodule BattleCityWeb.Components.StageComponent do
  use Phoenix.LiveDashboard.Web, :live_component

  alias BattleCity.Process.GameServer
  alias BattleCity.Stage

  @stage_prefix "STAGE"

  @impl true
  def mount(socket) do
    {:ok, assign(socket, stage: nil)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="tabular-info">
        <table class="table table-hover tabular-info-table">
          <tbody>
            <tr><td class="border-top-0">module</td><td class="border-top-0"><pre><%= @stage.__module__ %></pre></td></tr>
            <tr><td>name</td><td><pre><%= @stage.name %></pre></td></tr>
            <tr><td>difficulty</td><td><pre><%= @stage.difficulty %></pre></td></tr>
            <tr><td>bots</td><td><pre><%= Stage.format_bots(@stage) %></pre></td></tr>
            <tr><td>map</td><td><pre><%= Stage.format_map(@stage) %></pre></td></tr>
          </tbody>
        </table>
    </div>
    """
  end

  @impl true
  def update(%{id: @stage_prefix <> pid, path: path, return_to: return_to, page: page}, socket) do
    pid = :erlang.list_to_pid(String.to_charlist(pid))

    {:ok,
     assign(socket,
       stage: GameServer.ctx(pid).stage,
       pid: pid,
       path: path,
       page: page,
       return_to: return_to
     )}
  end
end
