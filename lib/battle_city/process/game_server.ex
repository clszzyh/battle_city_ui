defmodule BattleCity.Process.GameServer do
  @moduledoc false
  use GenServer
  use BattleCity.Process.ProcessRegistry

  alias BattleCity.Game

  def start_link({slug, opts}) do
    GenServer.start_link(__MODULE__, {slug, opts}, name: via_tuple(slug))
  end

  def ctx(srv), do: GenServer.call(srv, :ctx)
  def event(srv, event), do: GenServer.cast(srv, {:event, event})

  @impl true
  def init({slug, opts}) do
    ctx = Game.init(slug, opts)
    Process.send_after(self(), :loop, ctx.loop_interval)
    {:ok, ctx}
  end

  @impl true
  def handle_call(:ctx, _from, ctx), do: {:reply, ctx, ctx}

  @impl true
  def handle_cast({:event, event}, ctx) do
    ctx = Game.event(ctx, event)
    {:noreply, ctx}
  end

  @impl true
  def handle_info(:loop, ctx) do
    ctx = Game.loop(ctx)
    Process.send_after(self(), :loop, ctx.loop_interval)
    {:noreply, ctx}
  end
end
