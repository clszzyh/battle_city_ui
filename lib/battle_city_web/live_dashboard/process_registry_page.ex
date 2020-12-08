defmodule BattleCityWeb.LiveDashboard.ProcessRegistryPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  alias BattleCity.Process.ProcessRegistry
  alias BattleCity.Utils

  @title "Process Registry"

  @impl true
  def menu_link(_, _) do
    {:ok, @title}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :process_registry,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_processes/2,
      rows_name: "process",
      title: @title
    )
  end

  defp fetch_processes(params, _node) do
    # sessions = node |> :rpc.call(ProcessRegistry, :processes, [])
    processes = ProcessRegistry.search(params[:search])

    {Enum.take(processes, params[:limit]), length(processes)}
  end

  defp columns do
    [
      %{field: :module, sortable: :asc},
      %{field: :name, format: &Utils.inspect_wrapper/1},
      %{field: :pid, format: &encode_pid/1}
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
