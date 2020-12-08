defmodule BattleCityWeb.SetName do
  @moduledoc false

  import Plug.Conn
  alias BattleCity.Process.RandomWord

  def init(options), do: options

  def call(conn, _) do
    conn =
      if get_session(conn, :username) do
        conn
      else
        conn |> put_session(:username, RandomWord.username())
      end

    if get_session(conn, :slug) do
      conn
    else
      conn |> put_session(:slug, RandomWord.slug())
    end
  end
end
