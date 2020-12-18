defmodule BattleCityWeb.PlayLiveTest do
  use BattleCityWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Canvas is not supported!"
    assert render(page_live) =~ "Canvas is not supported!"
  end
end
