defmodule BattleCityWeb.Components.StageComponent do
  use Phoenix.LiveDashboard.Web, :live_component

  alias BattleCity.Display
  alias BattleCity.Process.GameServer

  @stage_prefix "STAGE"
  @environment_prefix "ENVIRONMENT"

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
            <%= for {k, v} <- @stage do %>
              <tr><td><%= k %></td><td><pre><%= v %></pre></td></tr>
            <% end %>
          </tbody>
        </table>
    </div>
    """
  end

  @impl true
  def update(%{id: @stage_prefix <> pids, path: path, return_to: return_to, page: page}, socket) do
    pid = :erlang.list_to_pid(String.to_charlist(pids))

    environment_fn = fn n, id ->
      live_patch(n, to: path.(node(pid), info: "#{@environment_prefix}#{pids};#{id}"))
    end

    {:ok,
     assign(socket,
       stage:
         Display.columns(GameServer.invoke_call(pid, :ctx).stage, environment_fn: environment_fn),
       pid: pid,
       path: path,
       page: page,
       return_to: return_to
     )}
  end
end
