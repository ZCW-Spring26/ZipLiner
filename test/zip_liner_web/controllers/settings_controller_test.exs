defmodule ZipLinerWeb.SettingsControllerTest do
  use ZipLinerWeb.ConnCase

  alias ZipLiner.Accounts

  describe "settings" do
    setup :log_in_member

    test "edit renders theme switch with light mode default", %{conn: conn} do
      conn = get(conn, ~p"/settings")
      html = html_response(conn, 200)

      assert html =~ "Use dark mode"
      assert html =~ ~s(name="member[theme_preference]")
      assert html =~ ~s(data-bs-theme="light")
    end

    test "update persists dark mode preference", %{conn: conn, member: member} do
      conn = put(conn, ~p"/settings", member: %{"theme_preference" => "dark"})
      assert redirected_to(conn) == ~p"/settings"

      updated_member = Accounts.get_member!(member.id)
      assert updated_member.theme_preference == :dark

      conn = get(recycle(conn), ~p"/settings")
      assert html_response(conn, 200) =~ ~s(data-bs-theme="dark")
    end
  end
end
