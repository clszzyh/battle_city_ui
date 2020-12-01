defmodule BattleCity do
  @moduledoc """
  BattleCity keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias BattleCity.Bullet
  alias BattleCity.Context
  alias BattleCity.Tank

  @type id :: binary()

  @type invoke_tank_result ::
          {Context.t(), Tank.t()} | Context.t() | Tank.t() | {:error, atom()} | :ignored

  @type inner_callback_bullet_result ::
          {Context.t(), Bullet.t()} | Context.t() | Bullet.t() | {:error, atom()} | :ignored
  @type callback_bullet_result :: {Context.t(), Bullet.t()}

  @type invoke_result :: {:error, atom()} | Context.t()

  @spec parse_tank_result(invoke_tank_result, Context.t(), Tank.t()) :: {Context.t(), Tank.t()}
  def parse_tank_result(%Context{} = ctx, _, %Tank{} = tank), do: {ctx, tank}
  def parse_tank_result(%Tank{} = tank, %Context{} = ctx, _), do: {ctx, tank}
  def parse_tank_result({%Context{} = ctx, %Tank{} = tank}, _, _), do: {ctx, tank}
  def parse_tank_result(:ignored, ctx, tank), do: {ctx, tank}
  def parse_tank_result({:error, _reason}, ctx, tank), do: {ctx, tank}
end
