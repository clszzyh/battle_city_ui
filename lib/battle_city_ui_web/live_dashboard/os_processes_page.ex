defmodule BattleCityUiWeb.LiveDashboard.OsProcessesPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  @impl true
  def menu_link(_, _) do
    {:ok, "OS Processes"}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :os_processes,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_processes/2,
      rows_name: "tables",
      title: "OS processes",
      sort_by: :PID
    )
  end

  defp fetch_processes(params, _node) do
    %{limit: limit, search: search, sort_by: sort_by, sort_dir: sort_dir} = params

    [head | tail] =
      System.cmd("ps", ["aux"])
      |> elem(0)
      |> String.split("\n", trim: true)
      |> Enum.map(fn row -> String.trim(row) |> String.split(~r/\s+/) end)

    keys = Enum.map(head, fn key -> key |> String.downcase() |> String.to_atom() end)

    data =
      tail
      |> filter_rows(search)
      |> Enum.map(fn values ->
        Enum.zip(keys, values)
        |> Map.new()
      end)
      |> Enum.take(limit)
      |> Enum.sort_by(&sort_value(&1, sort_by), sort_dir)

    {data, length(data)}
  end

  defp filter_rows(rows, nil), do: rows

  defp filter_rows(rows, search) do
    Enum.filter(rows, fn row -> filter_row(row, search) end)
  end

  defp filter_row(nil, _search), do: false
  defp filter_row(row, search), do: Enum.join(row, "") =~ search

  defp sort_value(map, key) do
    if check_if_int(map[key]) do
      String.to_integer(map[key])
    else
      map[key]
    end
  end

  defp check_if_int(maybe_int), do: Regex.match?(~r{\A\d*\z}, maybe_int)

  defp columns do
    [
      %{
        field: :pid,
        sortable: :asc
      },
      %{
        field: :tty
      },
      %{
        field: :time,
        cell_attrs: [class: "text-right"]
      },
      %{
        field: :user
      },
      %{
        field: :"%cpu",
        sortable: :desc
      },
      %{
        field: :"%mem",
        sortable: :desc
      },
      %{
        field: :vsz,
        sortable: :asc
      },
      %{
        field: :rss,
        sortable: :asc
      },
      %{
        field: :stat
      },
      %{
        field: :start,
        sortable: :asc
      },
      %{
        field: :command
      }
    ]
  end

  defp row_attrs(_table) do
    [
      {"phx-page-loading", true}
    ]
  end
end
