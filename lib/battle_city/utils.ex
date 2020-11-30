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
end
