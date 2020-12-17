defmodule BattleCity.Process.GameServer do
  @moduledoc false
  use GenServer
  use BattleCity.Process.ProcessRegistry

  alias BattleCity.Event
  alias BattleCity.Game
  alias BattleCity.Process.GameDynamicSupervisor
  alias BattleCity.Process.TankDynamicSupervisor

  def start_link({slug, opts}) do
    GenServer.start_link(__MODULE__, {slug, opts}, name: via_tuple(slug))
  end

  def invoke_call(srv, args), do: GenServer.call(srv, {:invoke, args})
  def invoke_cast(srv, args), do: GenServer.cast(srv, {:invoke, args})

  @impl true
  def init({slug, opts}) do
    ctx = Game.init(slug, opts)
    {:ok, ctx, {:continue, :loop}}
  end

  @impl true
  def handle_call({:invoke, :ctx}, _from, ctx), do: {:reply, ctx, ctx}
  def handle_call({:invoke, :loop}, from, ctx), do: handle_call({:invoke, {:loop, 1}}, from, ctx)

  def handle_call({:invoke, {:loop, times}}, _, ctx) do
    ctx =
      for _ <- 1..times, reduce: ctx do
        ctx -> Game.loop_ctx(ctx)
      end

    {:reply, {:ok, ctx}, ctx}
  end

  def handle_call({:invoke, :real_loop}, _, ctx) do
    ctx = Game.loop_ctx(ctx)

    for %{pid: pid} <- ctx.slug |> TankDynamicSupervisor.pid() |> TankDynamicSupervisor.children() do
      _ = send(pid, :loop)
    end

    {:reply, {:ok, ctx}, ctx}
  end

  def handle_call({:invoke, {"reset", %{} = opts}}, _from, ctx) do
    ctx = Game.init(ctx.slug, Map.merge(ctx.__opts__, opts))
    {:reply, {:ok, ctx}, ctx}
  end

  def handle_call({:invoke, {"reset", _}}, from, ctx) do
    handle_call({:invoke, {"reset", %{}}}, from, ctx)
  end

  def handle_call({:invoke, {"toggle_bot", "true"}}, _, %{enable_bot: true} = ctx) do
    ctx = %{ctx | enable_bot: false}
    {:reply, {:ok, ctx}, ctx}
  end

  def handle_call({:invoke, {"toggle_bot", "false"}}, _, %{enable_bot: false} = ctx) do
    ctx = %{ctx | enable_bot: true}
    {:reply, {:ok, ctx}, ctx, {:continue, :refresh_tanks}}
  end

  def handle_call({:invoke, {"toggle_pause", "started"}}, _, %{state: :started} = ctx),
    do: pause(ctx)

  def handle_call({:invoke, {"toggle_pause", "paused"}}, _, %{state: :paused} = ctx),
    do: resume(ctx)

  def handle_call({:invoke, {:event, %{name: :toggle_pause}}}, _, %{state: :started} = ctx),
    do: pause(ctx)

  def handle_call({:invoke, {:event, %{name: :toggle_pause}}}, _, %{state: :paused} = ctx),
    do: resume(ctx)

  def handle_call({:invoke, {:event, _}}, _, %{state: :paused} = ctx) do
    {:reply, {:paused, ctx}, ctx}
  end

  def handle_call({:invoke, {:plug, f}}, _, ctx) do
    {state, ctx} = f.(ctx)
    {:reply, {state, ctx}, ctx}
  end

  def handle_call({:invoke, {:event, event}}, _, ctx) do
    {ret, ctx} = Event.handle(ctx, event)
    {:reply, {ret, ctx}, ctx}
  end

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
  def handle_continue(:loop, ctx) do
    _ = do_loop(ctx)
    {:noreply, ctx}
  end

  def handle_continue(:refresh_tanks, ctx) do
    :ok = Game.refresh_tank_process(ctx.slug)
    {:noreply, ctx}
  end

  @impl true
  def terminate(reason, _state) do
    IO.puts("terminate server: #{inspect(reason)}")
    {:ok, reason}
  end

  defp pause(ctx) do
    ctx = %{ctx | state: :paused}
    {:reply, {:ok, ctx}, ctx, ctx.timeout_interval}
  end

  defp resume(ctx) do
    ctx = %{ctx | state: :started}
    _ = do_loop(ctx)
    {:reply, {:ok, ctx}, ctx, {:continue, :refresh_tanks}}
  end

  defp do_loop(%{mock: false, state: :started} = ctx),
    do: Process.send_after(self(), :loop, ctx.loop_interval)

  defp do_loop(_), do: :ok
end
