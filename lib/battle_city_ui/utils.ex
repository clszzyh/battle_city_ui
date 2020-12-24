defmodule BattleCityUi.Utils do
  @moduledoc false

  # @words_url "https://svnweb.freebsd.org/csrg/share/dict/words?view=co&content-type=text/plain"
  @prefix "priv/name_prefix.txt" |> File.read!() |> String.split([" ", "\n"], trim: true)
  @suffix "priv/name_suffix.txt" |> File.read!() |> String.split([" ", "\n"], trim: true)
  @words for p <- @prefix, s <- @suffix, do: "#{p}-#{s}"

  def username, do: Enum.random(@words) <> to_string(Enum.random(10..99))
  def slug, do: Enum.random(@prefix) <> to_string(:erlang.unique_integer([:positive]))
  # def random, do: Enum.random(@words)

  # def fetch_words do
  #   {:ok, {_meta, _header, body}} = :httpc.request(@words_url)
  #   words = body |> to_string |> String.split("\n", trim: true)
  #   %{count: Enum.count(words), words: words}
  # end

  def defined?(module) do
    module
    |> Code.ensure_compiled()
    |> case do
      {:module, _} -> true
      _ -> false
    end
  end

  @spec random(integer) :: binary()
  def random(length \\ 20) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.encode32(padding: false)
    |> binary_part(0, length)
  end

  @chars for(x <- ?A..?Z, do: <<x>>) ++ for(x <- ?a..?z, do: <<x>>) ++ for(x <- ?0..?9, do: <<x>>)

  def random_hex(length \\ 20) do
    1..length
    |> Enum.reduce([], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end

  @doc """
    iex> #{__MODULE__}.module_name(Foo.Bar.FooBar)
    :foo_bar
  """
  @spec module_name(module()) :: atom()
  def module_name(module) do
    module
    |> to_string
    |> String.split(".")
    |> List.last()
    |> Macro.underscore()
    |> String.to_atom()

    # module
    # |> to_string
    # |> String.trim_leading("Elixir.")
    # |> String.replace(".", "")
    # |> Macro.underscore()
    # |> String.to_atom()
  end

  def inspect_wrapper(o) when is_binary(o), do: o
  def inspect_wrapper(o), do: inspect(o)
end
