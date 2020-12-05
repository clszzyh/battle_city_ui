defmodule BattleCity.Display do
  @moduledoc false

  @spec columns(ComplexDisplay.t(), keyword()) :: keyword
  def columns(o, opts \\ []) do
    SimpleDisplay.columns(o) ++ ComplexDisplay.columns(o, opts)
  end
end

defprotocol SimpleDisplay do
  @fallback_to_any true

  @spec columns(t) :: keyword
  def columns(struct)
end

defimpl SimpleDisplay, for: Any do
  defmacro __deriving__(module, _, only: [_ | _] = only) do
    quote do
      defimpl SimpleDisplay, for: unquote(module) do
        def columns(arg) do
          for i <- unquote(only), do: {i, Map.fetch!(arg, i)}
        end
      end
    end
  end

  def columns(_), do: []
end

defprotocol ComplexDisplay do
  @spec columns(t, keyword) :: keyword
  def columns(struct, opts)
end

defimpl ComplexDisplay, for: BattleCity.Context do
  def columns(%{} = o, _) do
    [
      objects: o.objects |> Map.values() |> Enum.map(&MapSet.size/1) |> Enum.sum(),
      power_ups: Enum.count(o.power_ups),
      tanks: Enum.count(o.tanks),
      bullets: Enum.count(o.bullets)
    ]
  end
end

defimpl ComplexDisplay, for: BattleCity.Stage do
  def columns(%{__module__: module} = o, _) do
    [
      bots: o.bots |> Enum.map_join(", ", fn {m, c} -> "#{m.name()} -> #{c}" end),
      raw: module.__raw__() |> Enum.intersperse({:safe, "<br />"})
    ]
  end
end

defimpl ComplexDisplay, for: BattleCity.Tank do
  def columns(%{}, _) do
    []
  end
end
