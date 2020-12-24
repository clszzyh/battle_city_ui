defmodule BattleCityUiWeb.LiveDashboard.StagesPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  @title "Stages"

  @impl true
  def menu_link(_, _) do
    {:ok, @title}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :stages,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_processes/2,
      rows_name: "stages",
      title: @title
    )
  end

  @impl true
  def handle_event("click_module", %{"info" => "MODULE_" <> module}, socket) do
    module = String.to_atom(module)
    IO.puts("click module: #{inspect(module)}")
    {:noreply, socket}
  end

  defp fetch_processes(params, _node) do
    stages = []

    {Enum.take(stages, params[:limit]), length(stages)}
  end

  defp columns do
    [
      %{field: :name},
      %{field: :__module__, sortable: :asc},
      %{field: :difficulty},
      %{field: :bots},
      %{field: :raw}
    ]
  end

  defp row_attrs(row) do
    [
      {"phx-click", "click_module"},
      {"phx-value-info", "MODULE_#{row[:__module__]}"},
      {"phx-page-loading", true}
    ]
  end
end
