defmodule BattleCityWeb.LiveDashboard.ProcessRegistryPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  alias BattleCity.Process.ProcessRegistry

  @impl true
  def menu_link(_, _) do
    {:ok, "Process Registry"}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :process_registry,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_processes/2,
      rows_name: "process",
      title: "Process Registry"
    )
  end

  defp fetch_processes(params, _node) do
    # sessions = node |> :rpc.call(ProcessRegistry, :processes, [])
    processes = ProcessRegistry.list()

    {Enum.take(processes, params[:limit]), length(processes)}
  end

  defp columns do
    [
      %{field: :name, header: "name", sortable: :asc},
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

  # defp filter(sessions, _) do
  #   sessions
  #   # |> Enum.filter(fn session -> session_match?(session, params[:search]) end)
  #   # |> Enum.sort_by(fn session -> session[params[:sort_by]] end, params[:sort_dir])
  # end
end
