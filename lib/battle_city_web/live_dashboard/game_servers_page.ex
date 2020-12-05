defmodule BattleCityWeb.LiveDashboard.GameServersPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  alias BattleCity.Process.GameSupervisor

  @impl true
  def menu_link(_, _) do
    {:ok, "Game Servers"}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :game_servers,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_processes/2,
      rows_name: "servers",
      title: "Game Servers"
    )
  end

  defp fetch_processes(params, _node) do
    # sessions = node |> :rpc.call(ProcessRegistry, :processes, [])
    processes = GameSupervisor.children()

    {Enum.take(processes, params[:limit]), length(processes)}
  end

  defp columns do
    [
      %{
        field: :pid,
        header: "Worker PID",
        format: &(&1 |> encode_pid() |> String.replace_prefix("PID", ""))
      },
      %{field: :module, header: "module", sortable: :asc}
    ]
  end

  defp row_attrs(row) do
    [
      {"phx-click", "show_info"},
      {"phx-value-info", encode_pid(row[:pid])},
      {"phx-page-loading", true}
    ]
  end
end
