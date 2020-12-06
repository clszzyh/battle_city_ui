defmodule BattleCity.Display do
  @moduledoc false

  @spec columns(ComplexDisplay.t(), keyword()) :: keyword
  def columns(o, opts \\ []) do
    SimpleDisplay.columns(o) ++ ComplexDisplay.columns(o, Map.new(opts))
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
  @spec columns(t, map) :: keyword
  def columns(struct, opts)
end

defimpl ComplexDisplay, for: BattleCity.Context do
  def columns(%{} = o, %{stage_fn: stage_fn} = m) when is_function(stage_fn) do
    columns(o, %{m | stage_fn: nil}) ++ [stage: stage_fn.(o.stage.name)]
  end

  def columns(%{} = o, %{tank_fn: tank_fn} = m) when is_function(tank_fn) do
    tanks =
      o.tanks
      |> Enum.map(fn {id, %{position: p, __module__: module}} ->
        x = String.pad_leading(to_string(p.x), 2)
        y = String.pad_leading(to_string(p.y), 2)
        tank_fn.("{#{x} , #{y}} -> #{id} / [#{module.name()}]", id)
      end)
      |> Enum.intersperse({:safe, "<br />"})

    columns(o, %{m | tank_fn: nil}) ++ [tanks: tanks]
  end

  def columns(%{} = o, _) do
    [
      objects: o.objects |> Map.values() |> Enum.map(&MapSet.size/1) |> Enum.sum(),
      power_ups: Enum.count(o.power_ups),
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
