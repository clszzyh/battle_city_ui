defmodule BattleCity do
  @moduledoc """
  BattleCity keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias BattleCity.Context
  alias BattleCity.Tank

  @type tank_id :: binary()

  @type inner_callback_result :: {Context.t(), Tank.t()} | Context.t() | Tank.t()
  @type callback_result :: {Context.t(), Tank.t()}

  @spec parse_result(inner_callback_result, Context.t(), Tank.t()) :: callback_result
  def parse_result(%Context{} = ctx, _, %Tank{} = tank), do: {ctx, tank}
  def parse_result(%Tank{} = tank, %Context{} = ctx, _), do: {ctx, tank}
  def parse_result({%Context{} = ctx, %Tank{} = tank}, _, _), do: {ctx, tank}
end
