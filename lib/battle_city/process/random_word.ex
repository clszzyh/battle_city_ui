defmodule BattleCity.Process.RandomWord do
  @moduledoc false
  use GenServer

  # @words_url "https://svnweb.freebsd.org/csrg/share/dict/words?view=co&content-type=text/plain"
  @prefix "priv/name_prefix.txt" |> File.read!() |> String.split([" ", "\n"], trim: true)
  @suffix "priv/name_suffix.txt" |> File.read!() |> String.split([" ", "\n"], trim: true)
  @words for p <- @prefix, s <- @suffix, do: "#{p}-#{s}"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def random, do: GenServer.call(__MODULE__, :random)

  @impl true
  def init(_) do
    {:ok, %{count: Enum.count(@words), words: @words}}
  end

  @impl true
  def handle_call(:random, _, %{words: words} = state) do
    {:reply, Enum.random(words) <> to_string(Enum.random(10..99)), state}
  end

  # @impl true
  # def handle_continue(:fetch_words, state) do
  #   if Mix.env() == :prod do
  #     {:noreply, fetch_words()}
  #   else
  #     {:noreply, state}
  #   end
  # end

  # def fetch_words do
  #   {:ok, {_meta, _header, body}} = :httpc.request(@words_url)
  #   words = body |> to_string |> String.split("\n", trim: true)
  #   %{count: Enum.count(words), words: words}
  # end
end
