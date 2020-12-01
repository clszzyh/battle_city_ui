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

  def random(length \\ 20) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz" |> String.split("")

  def random_hex(length \\ 20) do
    1..length
    |> Enum.reduce([], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end
end
