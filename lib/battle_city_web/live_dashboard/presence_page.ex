defmodule BattleCityWeb.LiveDashboard.PresencePage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  alias BattleCity.Utils

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

  defp fetch_processes(%{sort_by: sort_by, sort_dir: sort_dir, limit: limit}, _node) do
    data =
      BattleCityWeb.Presence.list_liveview() |> Enum.sort_by(fn x -> x[sort_by] end, sort_dir)

    {Enum.take(data, limit), length(data)}
  end

  defp columns do
    [
      %{field: :slug, sortable: :asc},
      %{field: :name, sortable: :asc},
      %{field: :pid, format: &encode_pid/1},
      %{field: :key},
      %{field: :phx_ref},
      %{field: :address, format: &Utils.inspect_wrapper/1},
      %{field: :port},
      %{field: "_mounts"}
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
