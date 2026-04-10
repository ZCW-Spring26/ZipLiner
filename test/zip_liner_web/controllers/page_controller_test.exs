defmodule ZipLinerWeb.PageControllerTest do
  use ZipLinerWeb.ConnCase

  test "GET / redirects to /feed when logged in", %{conn: conn} do
    member = ZipLiner.AccountsFixtures.member_fixture()
    conn = log_in_member(conn, member)
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/feed"
  end

  test "GET / renders home page when not logged in", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Welcome to ZipLiner"
  end
end
