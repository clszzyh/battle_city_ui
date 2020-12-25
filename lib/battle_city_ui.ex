defmodule BattleCityUi do
  @moduledoc """
  BattleCityUi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @rev System.get_env("SOURCE_VERSION", "master")
  @source_url Mix.Project.config()[:docs][:source_url] <> "/commit/" <> @rev
  @version Mix.Project.config()[:version] <> "_" <> @rev

  def source_url, do: @source_url
  def version, do: @version
end
