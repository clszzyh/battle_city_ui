defmodule BattleCity.Debugger do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      require IEx
      # credo:disable-for-next-line
      "-" |> String.duplicate(:io.columns() |> elem(1)) |> IO.write()
      # credo:disable-for-next-line
      IO.inspect(binding(), pretty: true)
      # credo:disable-for-next-line
      "-" |> String.duplicate(:io.columns() |> elem(1)) |> IO.write()
      # credo:disable-for-next-line
      IEx.pry()
    end
  end
end
