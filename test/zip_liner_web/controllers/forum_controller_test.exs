defmodule ZipLinerWeb.ForumControllerTest do
  use ZipLinerWeb.ConnCase

  alias ZipLiner.AccountsFixtures
  alias ZipLiner.ForumsFixtures

  describe "index" do
    setup :log_in_member

    test "lists all threads", %{conn: conn} do
      conn = get(conn, ~p"/forums")
      assert html_response(conn, 200) =~ "Forum"
    end

    test "shows thread in listing", %{conn: conn, member: member} do
      ForumsFixtures.thread_fixture(member.id, %{title: "My Discussion Thread"})
      conn = get(conn, ~p"/forums")
      assert html_response(conn, 200) =~ "My Discussion Thread"
    end
  end

  describe "new" do
    setup :log_in_member

    test "renders new thread form", %{conn: conn} do
      conn = get(conn, ~p"/forums/new")
      assert html_response(conn, 200) =~ "New Thread"
    end
  end

  describe "create" do
    setup :log_in_member

    test "creates thread and redirects to show", %{conn: conn} do
      conn =
        post(conn, ~p"/forums", %{
          "forum_thread" => %{"title" => "New Thread Title", "body" => "Thread body content"}
        })

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/forums/#{id}"
    end

    test "renders errors when title is missing", %{conn: conn} do
      conn =
        post(conn, ~p"/forums", %{
          "forum_thread" => %{"title" => "", "body" => "Some body"}
        })

      assert html_response(conn, 200) =~ "New Thread"
    end
  end

  describe "show" do
    setup :log_in_member

    test "shows thread with title and body", %{conn: conn, member: member} do
      thread = ForumsFixtures.thread_fixture(member.id, %{title: "Shown Thread", body: "Body text here"})
      conn = get(conn, ~p"/forums/#{thread.id}")
      assert html_response(conn, 200) =~ "Shown Thread"
      assert html_response(conn, 200) =~ "Body text here"
    end

    test "shows add comment form", %{conn: conn, member: member} do
      thread = ForumsFixtures.thread_fixture(member.id)
      conn = get(conn, ~p"/forums/#{thread.id}")
      assert html_response(conn, 200) =~ "Add a Comment"
    end

    test "owner sees delete button", %{conn: conn, member: member} do
      thread = ForumsFixtures.thread_fixture(member.id)
      conn = get(conn, ~p"/forums/#{thread.id}")
      assert html_response(conn, 200) =~ "Delete"
    end

    test "non-owner does not see delete button", %{conn: conn} do
      other = AccountsFixtures.member_fixture()
      thread = ForumsFixtures.thread_fixture(other.id)
      conn = get(conn, ~p"/forums/#{thread.id}")
      refute html_response(conn, 200) =~ "Delete"
    end
  end

  describe "delete" do
    setup :log_in_member

    test "owner can delete thread", %{conn: conn, member: member} do
      thread = ForumsFixtures.thread_fixture(member.id)
      conn = delete(conn, ~p"/forums/#{thread.id}")
      assert redirected_to(conn) == ~p"/forums"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "deleted"
    end

    test "non-owner cannot delete thread", %{conn: conn} do
      other = AccountsFixtures.member_fixture()
      thread = ForumsFixtures.thread_fixture(other.id)
      conn = delete(conn, ~p"/forums/#{thread.id}")
      assert redirected_to(conn) == ~p"/forums"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "only delete your own"
    end

    test "admin can delete any thread", %{conn: conn} do
      admin = AccountsFixtures.member_fixture(%{is_admin: true})
      other = AccountsFixtures.member_fixture()
      thread = ForumsFixtures.thread_fixture(other.id)

      conn = log_in_member(conn, admin)
      conn = delete(conn, ~p"/forums/#{thread.id}")
      assert redirected_to(conn) == ~p"/forums"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "deleted"
    end
  end

  describe "unauthenticated access" do
    test "redirects to home when not logged in", %{conn: conn} do
      conn = get(conn, ~p"/forums")
      assert redirected_to(conn) == ~p"/"
    end
  end
end
