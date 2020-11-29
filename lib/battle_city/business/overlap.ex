defmodule BattleCity.Business.Overlap do
  @moduledoc false

  alias BattleCity.Context
  alias BattleCity.Position
  alias BattleCity.PowerUp
  alias BattleCity.Tank

  @typep f :: BattleCity.fingerprint()
  @typep resolve_args :: {Position.coordinate(), [f() | [f() | []]]}

  @spec resolve(Context.t()) :: Context.t()
  def resolve(%Context{objects: objects} = ctx) do
    objects
    |> Enum.flat_map(fn {xy, %MapSet{} = mapset} ->
      for i <- mapset, j <- mapset, i != j, uniq: true, do: {xy, MapSet.new([i, j])}
    end)
    |> Enum.map(fn {xy, mapset} -> {xy, MapSet.to_list(mapset)} end)
    |> Enum.reduce(ctx, &do_resolve/2)
  end

  ### tank > power_ups > bullet
  @spec do_resolve(resolve_args, Context.t()) :: Context.t()
  defp do_resolve({o, [{:b, _, _} = f1, {:p, _, _} = f2]}, ctx),
    do: do_resolve({o, [f2, f1]}, ctx)

  defp do_resolve({o, [{:p, _, _} = f1, {:t, _, _} = f2]}, ctx),
    do: do_resolve({o, [f2, f1]}, ctx)

  defp do_resolve({o, [{:b, _, _} = f1, {:t, _, _} = f2]}, ctx),
    do: do_resolve({o, [f2, f1]}, ctx)

  defp do_resolve({_, [{:t, _, _}, {:t, _, _}]}, ctx), do: ctx
  defp do_resolve({_, [{:p, _, _}, {:p, _, _}]}, ctx), do: ctx
  defp do_resolve({_, [{:p, _, _}, {:b, _, _}]}, ctx), do: ctx

  defp do_resolve({_, [{:b, _, bol}, {:b, _, bol}]}, ctx), do: ctx

  defp do_resolve({_, [{:b, bid1, _}, {:b, bid2, _}]}, ctx) do
    ctx |> Context.delete_object(:bullets, bid1) |> Context.delete_object(:bullets, bid2)
  end

  defp do_resolve({_, [{:t, _, bol}, {:b, _, bol}]}, ctx), do: ctx

  defp do_resolve({_, [{:t, tid, _}, {:b, bid, _}]}, ctx) do
    bullet = Context.fetch_object!(ctx, :bullets, bid)
    tank = Context.fetch_object!(ctx, :tanks, tid)
    tank = Tank.hit(tank, bullet)
    ctx |> Context.delete_object(:bullets, bid) |> Context.put_object(tank)
  end

  defp do_resolve({_, {:t, tid, _}, {:p, pid, _}}, ctx) do
    power_up = Context.fetch_object!(ctx, :power_ups, pid)
    tank = Context.fetch_object!(ctx, :tanks, tid)
    tank = PowerUp.add(tank, power_up)
    ctx |> Context.delete_object(:power_ups, pid) |> Context.put_object(tank)
  end
end
