defmodule BattleCityWeb.SetName do
  @moduledoc false

  import Plug.Conn
  alias BattleCity.Utils

  def init(options), do: options

  def call(conn, _) do
    conn =
      if get_session(conn, :username) do
        conn
      else
        conn |> put_session(:username, Utils.username())
      end

    if get_session(conn, :slug) do
      conn
    else
      conn |> put_session(:slug, Utils.slug())
    end
  end
end
