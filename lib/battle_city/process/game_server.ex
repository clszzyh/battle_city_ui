defmodule BattleCity.Process.GameServer do
  @moduledoc false
  use GenServer
  use BattleCity.Process.ProcessRegistry

  alias BattleCity.Context

  @type t :: %__MODULE__{
          context: Context.t(),
          name: binary
        }
  defstruct [:context, :name]

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  @impl true
  def init(name) do
    {:ok, %__MODULE__{context: Context.init(), name: name}}
  end
end
