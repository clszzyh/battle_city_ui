defmodule BattleCity.Process.StageCache do
  @moduledoc false

  use GenServer

  defstruct stages: %{}, names: MapSet.new()

  alias BattleCity.Display

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    modules = BattleCity.Compile.compile_stage!()
    names = for m <- modules, into: MapSet.new(), do: m.name()
    stages = for m <- modules, into: %{}, do: {m.name(), m}

    {:ok, %__MODULE__{names: names, stages: stages}}
  end

  def stages, do: GenServer.call(__MODULE__, :stages)

  def stages_show do
    for {_, s} <- stages(), do: Display.columns(s.init)
  end

  def names, do: GenServer.call(__MODULE__, :names)
  def fetch_stage(name), do: GenServer.call(__MODULE__, {:fetch_stage, name})
  def put_stage(module), do: GenServer.cast(__MODULE__, {:put_stage, module})

  # @impl true
  # def handle_continue(:init_stage, state) do
  #   BattleCity.Compile.compile_stage!()
  #   {:noreply, state}
  # end

  @impl true
  def handle_call(:stages, _from, state) do
    {:reply, state.stages, state}
  end

  @impl true
  def handle_call(:names, _from, state) do
    {:reply, state.names, state}
  end

  @impl true
  def handle_call({:fetch_stage, name}, _from, state) do
    {:reply, Map.fetch!(state.stages, name), state}
  end

  @impl true
  def handle_cast({:put_stage, module}, %__MODULE__{stages: stages, names: names} = state) do
    {:noreply,
     %{
       state
       | names: MapSet.put(names, module.name()),
         stages: Map.put(stages, module.name(), module)
     }}
  end
end
