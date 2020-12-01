defmodule BattleCity.PowerUp do
  @moduledoc false

  alias BattleCity.Config
  alias BattleCity.Context
  alias BattleCity.Tank

  @type duration :: integer() | :instant

  @type t :: %__MODULE__{
          __module__: module(),
          id: BattleCity.id(),
          duration: duration()
        }

  @enforce_keys []
  defstruct [
    :__module__,
    :id,
    duration: Config.power_up_duration()
  ]

  use BattleCity.StructCollect

  @callback handle_on(Context.t(), Tank.t()) :: BattleCity.invoke_tank_result()
  @callback handle_off(Context.t(), Tank.t()) :: BattleCity.invoke_tank_result()
  @optional_callbacks handle_off: 2

  defmacro __using__(opt \\ []) do
    obj = struct!(__MODULE__, opt)

    quote location: :keep do
      alias BattleCity.Business
      alias BattleCity.Context
      alias BattleCity.Tank

      init_ast(unquote(__MODULE__), __MODULE__, unquote(Macro.escape(obj)))
    end
  end

  @spec on(Context.t(), Tank.t(), __MODULE__.t()) :: BattleCity.invoke_result()
  def on(%Context{} = ctx, %Tank{} = tank, %__MODULE__{} = powerup) do
    powerup.__module__.handle_on(ctx, tank)
    |> BattleCity.parse_tank_result(ctx, tank)
    |> Context.put_tank()
  end

  @spec off(Context.t(), Tank.t(), __MODULE__.t()) :: BattleCity.invoke_result()
  def off(%Context{} = ctx, %Tank{} = tank, %__MODULE__{} = powerup) do
    if function_exported?(powerup.__module__, :handle_off, 2) do
      powerup.__module__.handle_off(ctx, tank)
      |> BattleCity.parse_tank_result(ctx, tank)
      |> Context.put_tank()
    else
      Context.put_tank(ctx, tank)
    end
  end
end
