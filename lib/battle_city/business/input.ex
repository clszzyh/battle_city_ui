defmodule BattleCity.Business.Input do
  @moduledoc false

  alias BattleCity.Context
  alias BattleCity.Event
  alias BattleCity.Tank

  @spec operate(Context.t(), Tank.t(), Event.t()) :: BattleCity.invoke_result()
  def operate(_, %Tank{dead?: true}, _) do
    {:error, :dead}
  end

  def operate(_, %Tank{freezed?: true}, %Event{name: :move}) do
    {:error, :freezed}
  end

  def operate(%Context{} = ctx, %Tank{} = tank, %Event{name: :move}) do
    ctx |> Context.put_tank(%{tank | moving?: true})
  end

  def operate(_, %Tank{shootable?: false}, %Event{name: :shoot}) do
    {:error, :disabled}
  end

  def operate(
        %Context{} = ctx,
        %Tank{__module__: module} = tank,
        %Event{name: :shoot} = event
      ) do
    bullet = module.create_bullet(tank, event)
    ctx |> Context.put_tank(%{tank | shootable?: false}) |> Context.put_bullet(bullet)
  end
end
