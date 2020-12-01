defmodule BattleCity.Utils do
  @moduledoc false
  def defined?(module) when is_atom(module) do
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
    |> Base.url_encode64(padding: false)
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
end
