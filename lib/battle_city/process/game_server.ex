defmodule BattleCity.Process.GameServer do
  @moduledoc false
  use GenServer
  use BattleCity.Process.ProcessRegistry

  alias BattleCity.Game

  def start_link({slug, opts}) do
    GenServer.start_link(__MODULE__, {slug, opts}, name: via_tuple(slug))
  end

  def ctx(srv), do: GenServer.call(srv, :ctx)
  def pause(srv), do: GenServer.cast(srv, :pause)
  def resume(srv), do: GenServer.cast(srv, :resume)
  def event(srv, event), do: GenServer.cast(srv, {:event, event})

  @impl true
  def init({slug, opts}) do
    ctx = Game.init(slug, opts)
    Process.send_after(self(), :loop, ctx.loop_interval)
    {:ok, ctx, ctx.timeout_interval}
  end

  @impl true
  def handle_call(:ctx, _from, ctx), do: {:reply, ctx, ctx, ctx.timeout_interval}

  @impl true
  def handle_cast(:pause, %{state: :started} = ctx), do: handle_pause(ctx)
  def handle_cast(:pause, ctx), do: {:noreply, ctx, ctx.timeout_interval}
  def handle_cast(:resume, %{state: :paused} = ctx), do: handle_resume(ctx)
  def handle_cast(:resume, ctx), do: {:noreply, ctx}
  def handle_cast({:event, {:toggle_pause, nil}}, %{state: :started} = ctx), do: handle_pause(ctx)
  def handle_cast({:event, {:toggle_pause, nil}}, %{state: :paused} = ctx), do: handle_resume(ctx)

  def handle_cast({:event, event}, ctx) do
    ctx = Game.event(ctx, event)
    {:noreply, ctx, ctx.timeout_interval}
  end

  @impl true
  def handle_info(:loop, %{state: :started} = ctx) do
    ctx = Game.loop(ctx)
    _ = loop(ctx)
    {:noreply, ctx}
  end

  def handle_info(:loop, ctx), do: {:noreply, ctx, ctx.timeout_interval}

  def handle_info(:timeout, ctx) do
    IO.puts("timeout: #{ctx.slug}")
    {:noreply, ctx}
  end

  @impl true
  def terminate(reason, _state) do
    {:ok, reason}
  end

  defp handle_pause(ctx) do
    {:noreply, %{ctx | state: :paused}, ctx.timeout_interval}
  end

  defp handle_resume(ctx) do
    _ = loop(ctx)
    {:noreply, %{ctx | state: :started}, ctx.timeout_interval}
  end

  defp loop(ctx) do
    Process.send_after(self(), :loop, ctx.loop_interval)
  end
end
