defmodule FileInfo do
  require Record
  Record.defrecord(:file_info, Record.extract(:file_info, from_lib: "kernel/include/file.hrl"))
end

defmodule SystemLogParser do
  import NimbleParsec

  date =
    ascii_string([?a..?z, ?A..?Z], 3)
    |> ignore(ascii_string([?\s], min: 1, max: 2))
    |> ascii_string([?0..?9], min: 1, max: 2)
    |> ignore(string(" "))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)

  hostname = ascii_string([?a..?z, ?A..?Z, ?-], min: 1)
  from = ascii_string([not: ?:], min: 1)
  message = ascii_string([not: ?\n], min: 1)

  defparsec(:date, date)

  defparsec(
    :parse,
    date
    |> ignore(string(" "))
    |> concat(hostname)
    |> ignore(string(" "))
    |> concat(from)
    |> ignore(string(":"))
    |> ignore(string(" "))
    |> concat(message)
    |> eos()
  )

  def parsed_line_to_map(
        {:ok, [month, date, hour, minute, second, hostname, from, message], _, _, _, _}
      ) do
    %{
      time: "#{month} #{date}, #{hour}:#{minute}:#{second}",
      hostname: hostname,
      from: from,
      message: message
    }
  end
end

defmodule BattleCityUiWeb.LiveDashboard.SystemLogPage do
  @moduledoc """
  https://dev.to/dkuku/nginx-logs-in-live-dashboard-jk9
  """
  use Phoenix.LiveDashboard.PageBuilder
  import FileInfo

  @title "System Log"

  @path "/var/log/system.log"
  @avg_line_lenght 200

  @impl true
  def menu_link(_, _) do
    {:ok, @title}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :logs,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_logs/2,
      rows_name: "logs",
      title: @title
    )
  end

  defp fetch_logs(params, node) do
    data = :rpc.call(node, __MODULE__, :logs_callback, [params])

    {data, length(data)}
  end

  def logs_callback(%{limit: limit, sort_by: sort_by, sort_dir: sort_dir} = params) do
    with {:ok, pid} <- :file.open(@path, [:binary]),
         {:ok, info} <- :file.read_file_info(pid),
         {:ok, file_size} <- Keyword.fetch(file_info(info), :size),
         {:ok, content} <- get_data(pid, params, file_size),
         :ok <- :file.close(pid) do
      content
      |> Enum.sort_by(&sort_value(&1, sort_by), sort_dir)
      |> Enum.take(limit)
    else
      error ->
        IO.puts(inspect({params, error}))
        []
    end
  end

  def get_data(pid, params, load_from, offset \\ 0, data \\ [])
  def get_data(_pid, _params, 0 = _load_from, _offset, data), do: {:ok, data}

  def get_data(pid, %{limit: limit, search: search} = params, load_from, last_line_offset, data) do
    chunk_size = limit * @avg_line_lenght

    {load_from, buffer_size} =
      if load_from - chunk_size < 0 do
        {0, load_from + last_line_offset}
      else
        {load_from - chunk_size, chunk_size + last_line_offset}
      end

    [first_line | full_lines_chunk] = get_data_chunk(pid, load_from, buffer_size)

    updated_data = parse_chunk(full_lines_chunk, search) ++ data

    newlines = Enum.count(updated_data)

    if newlines < limit do
      get_data(pid, params, load_from, byte_size(first_line), updated_data)
    else
      {:ok, updated_data}
    end
  end

  defp get_data_chunk(pid, load_from, buffer_size) do
    case :file.pread(pid, [{load_from, buffer_size}]) do
      {:ok, [:eof]} -> ""
      {:ok, [content]} -> content
      _ -> ""
    end
    |> :binary.split(<<"\n">>, [:global])
  end

  defp parse_chunk(data, search) do
    data
    |> filter_rows(search)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&SystemLogParser.parse/1)
    |> Stream.filter(fn parsed -> parsed |> elem(0) == :ok end)
    |> Enum.map(&SystemLogParser.parsed_line_to_map/1)
  end

  defp filter_rows(rows, nil), do: rows

  defp filter_rows(rows, search) do
    Stream.filter(rows, fn row -> include_row?(row, search) end)
  end

  defp include_row?(nil, _search), do: false
  defp include_row?("", _search), do: false
  defp include_row?(row, search), do: row =~ search

  defp sort_value(map, key), do: Map.get(map, key)

  defp columns do
    [
      %{field: :time, sortable: :desc},
      %{field: :hostname},
      %{field: :from},
      %{field: :message}
    ]
  end

  defp row_attrs(_row) do
    [
      {"phx-page-loading", true}
    ]
  end
end
