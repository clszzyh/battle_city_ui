defmodule BattleCityWeb.LiveDashboard.GameServersPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  alias BattleCity.Process.GameSupervisor

  @title "Game Servers"

  @impl true
  def menu_link(_, _) do
    {:ok, @title}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :game_servers,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_processes/2,
      rows_name: "servers",
      title: @title
    )
  end

  defp fetch_processes(params, _node) do
    processes = GameSupervisor.children()

    {Enum.take(processes, params[:limit]), length(processes)}
  end

  @impl true
  def handle_event("click_pid", %{"info" => "PID" <> pid_str}, socket) do
    pid = :erlang.list_to_pid(String.to_charlist(pid_str))
    IO.puts("click pid: #{inspect(pid)}")
    {:noreply, socket}
  end

  defp columns do
    [
      %{field: :pid, format: &encode_pid/1},
      %{field: :module, sortable: :asc}
    ]
  end

  defp row_attrs(row) do
    [
      {"phx-click", "click_pid"},
      {"phx-value-info", encode_pid(row[:pid])},
      {"phx-page-loading", true}
    ]
  end
end
