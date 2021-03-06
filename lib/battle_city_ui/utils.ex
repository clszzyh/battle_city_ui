defmodule BattleCityUi.Utils do
  @moduledoc false

  # @words_url "https://svnweb.freebsd.org/csrg/share/dict/words?view=co&content-type=text/plain"
  @prefix "priv/name_prefix.txt" |> File.read!() |> String.split([" ", "\n"], trim: true)
  @suffix "priv/name_suffix.txt" |> File.read!() |> String.split([" ", "\n"], trim: true)
  @words for p <- @prefix, s <- @suffix, do: "#{p}-#{s}"

  def username, do: Enum.random(@words) <> to_string(Enum.random(10..99))
  def slug, do: Enum.random(@prefix) <> to_string(:erlang.unique_integer([:positive]))

  def inspect_wrapper(o) when is_binary(o), do: o
  def inspect_wrapper(o), do: inspect(o)
end
