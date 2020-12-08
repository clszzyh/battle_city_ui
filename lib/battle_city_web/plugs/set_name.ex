defmodule BattleCityWeb.SetName do
  @moduledoc false

  import Plug.Conn
  alias BattleCity.Process.RandomWord

  def init(options), do: options

  def call(conn, _) do
    if get_session(conn, :username) do
      conn
    else
      conn |> put_session(:username, RandomWord.random())
    end
  end
end
