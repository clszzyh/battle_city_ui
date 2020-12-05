defmodule BattleCityWeb.LiveDashboard.StagesPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  alias BattleCity.Process.StageCache

  @impl true
  def menu_link(_, _) do
    {:ok, "Stages"}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :stages,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_processes/2,
      rows_name: "stages",
      title: "Stages"
    )
  end

  defp fetch_processes(params, _node) do
    # sessions = node |> :rpc.call(ProcessRegistry, :processes, [])
    processes = StageCache.stages_show()

    {Enum.take(processes, params[:limit]), length(processes)}
  end

  defp columns do
    [
      %{field: :name},
      %{field: :module, sortable: :asc},
      %{field: :difficulty},
      %{field: :bots},
      %{field: :raw, format: &format_value(&1, nil)}
    ]
  end

  defp row_attrs(_row) do
    []
  end
end
