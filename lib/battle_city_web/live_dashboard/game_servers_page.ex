defmodule BattleCityWeb.LiveDashboard.GameServersPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  alias BattleCity.Process.ProcessRegistry

  @title "Game Servers"
  @context_prefix "CONTEXT"
  @stage_prefix "STAGE"
  @tank_prefix "TANK"

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
    processes = ProcessRegistry.games()

    {Enum.take(processes, params[:limit]), length(processes)}
  end

  def component(@context_prefix <> _), do: BattleCityWeb.Components.ContextComponent
  def component(@stage_prefix <> _), do: BattleCityWeb.Components.StageComponent
  def component(@tank_prefix <> _), do: BattleCityWeb.Components.TankComponent

  defp columns do
    [
      %{field: :name, sortable: :asc},
      %{field: :pid, format: &encode_pid/1},
      %{field: :tank_sup, format: &encode_pid/1},
      %{field: :active},
      %{field: :workers}
    ]
  end

  defp row_attrs(row) do
    [
      {"phx-click", "show_info"},
      {"phx-value-info", "#{@context_prefix}#{:erlang.pid_to_list(row[:pid])}"},
      {"phx-page-loading", true}
    ]
  end
end
