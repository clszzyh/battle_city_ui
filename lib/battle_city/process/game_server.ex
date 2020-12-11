defmodule BattleCity.Process.GameServer do
  @moduledoc false
  use GenServer
  use BattleCity.Process.ProcessRegistry

  alias BattleCity.Game
  alias BattleCity.Process.GameDynamicSupervisor

  def start_link({slug, opts}) do
    GenServer.start_link(__MODULE__, {slug, opts}, name: via_tuple(slug))
  end

  def ctx(srv), do: GenServer.call(srv, :ctx)
  def pause(srv), do: GenServer.cast(srv, :pause)
  def resume(srv), do: GenServer.cast(srv, :resume)
  def event(srv, event), do: GenServer.call(srv, {:event, event})
  def loop(srv, times \\ 1), do: GenServer.call(srv, {:loop, times})

  @impl true
  def init({slug, opts}) do
    ctx = Game.init(slug, opts)
    _ = do_loop(ctx)
    {:ok, ctx, ctx.timeout_interval}
  end

  @impl true
  def handle_call(:ctx, _from, ctx), do: {:reply, ctx, ctx, ctx.timeout_interval}

  def handle_call({:event, %{name: :toggle_pause}}, _, %{state: :started} = ctx) do
    do_pause(ctx, :reply)
  end

  def handle_call({:event, %{name: :toggle_pause}}, _, %{state: :paused} = ctx) do
    do_resume(ctx, :reply)
  end

  def handle_call({:event, _}, _, %{state: :paused} = ctx) do
    {:reply, ctx, ctx, ctx.timeout_interval}
  end

  def handle_call({:event, event}, _, ctx) do
    ctx = Game.event(ctx, event)
    {:reply, ctx, ctx, ctx.timeout_interval}
  end

  def handle_call({:loop, times}, _, ctx) do
    ctx =
      for _ <- 1..times, reduce: ctx do
        ctx -> Game.loop_ctx(ctx)
      end

    {:reply, ctx, ctx}
  end

  @impl true
  def handle_cast(:pause, %{state: :started} = ctx), do: do_pause(ctx, :noreply)
  def handle_cast(:pause, ctx), do: {:noreply, ctx, ctx.timeout_interval}
  def handle_cast(:resume, %{state: :paused} = ctx), do: do_resume(ctx, :noreply)
  def handle_cast(:resume, ctx), do: {:noreply, ctx}

  @impl true
  def handle_info(:loop, %{state: :started} = ctx) do
    ctx = Game.loop_ctx(ctx)
    _ = do_loop(ctx)
    {:noreply, ctx}
  end

  def handle_info(:loop, ctx), do: {:noreply, ctx, ctx.timeout_interval}

  def handle_info(:timeout, ctx) do
    :ok = GameDynamicSupervisor.terminate_child(ctx.slug)
    {:noreply, ctx}
  end

  @impl true
  def terminate(reason, _state) do
    {:ok, reason}
  end

  defp do_pause(ctx, :noreply) do
    {:noreply, %{ctx | state: :paused}, ctx.timeout_interval}
  end

  defp do_pause(ctx, :reply) do
    ctx = %{ctx | state: :paused}
    {:reply, ctx, ctx, ctx.timeout_interval}
  end

  defp do_resume(ctx, :noreply) do
    _ = do_loop(ctx)
    {:noreply, %{ctx | state: :started}, ctx.timeout_interval}
  end

  defp do_resume(ctx, :reply) do
    ctx = %{ctx | state: :started}
    _ = do_loop(ctx)
    {:reply, ctx, ctx, ctx.timeout_interval}
  end

  defp do_loop(%{mock: true}), do: :ok
  defp do_loop(ctx), do: Process.send_after(self(), :loop, ctx.loop_interval)
end
