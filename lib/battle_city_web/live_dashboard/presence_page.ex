defmodule BattleCityWeb.LiveDashboard.PresencePage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  @title "Presence"

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
      rows_name: "presence",
      title: @title
    )
  end

  defp fetch_processes(params, _node) do
    data = BattleCityWeb.Presence.list_liveview()

    {Enum.take(data, params[:limit]), length(data)}
  end

  defp columns do
    [
      %{field: :slug, sortable: :asc},
      %{field: :pid, format: &encode_pid/1},
      %{field: :key},
      %{field: :ref}
    ]
  end

  defp row_attrs(_row) do
    []
  end
end
