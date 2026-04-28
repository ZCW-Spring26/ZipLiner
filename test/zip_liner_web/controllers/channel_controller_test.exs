defmodule ZipLinerWeb.ChannelControllerTest do
  use ZipLinerWeb.ConnCase

  alias ZipLiner.AccountsFixtures
  alias ZipLiner.BlogFixtures

  describe "index" do
    setup :log_in_member

    test "renders channels page", %{conn: conn} do
      conn = get(conn, ~p"/channels")
      assert html_response(conn, 200) =~ "Channels"
    end

    test "shows members who have written articles", %{conn: conn} do
      author = AccountsFixtures.member_fixture()
      BlogFixtures.article_fixture(author.id, %{title: "Author's Post"})
      conn = get(conn, ~p"/channels")
      assert html_response(conn, 200) =~ author.display_name
    end

    test "shows member blog title when set", %{conn: conn} do
      author = AccountsFixtures.member_fixture()
      {:ok, author} = ZipLiner.Accounts.update_member(author, %{blog_title: "My Amazing Blog"})
      BlogFixtures.article_fixture(author.id)
      conn = get(conn, ~p"/channels")
      assert html_response(conn, 200) =~ "My Amazing Blog"
    end

    test "shows empty state when no channels exist", %{conn: conn} do
      conn = get(conn, ~p"/channels")
      assert html_response(conn, 200) =~ "No channels yet"
    end
  end

  describe "show" do
    setup :log_in_member

    test "shows member's blog page", %{conn: conn} do
      author = AccountsFixtures.member_fixture()
      BlogFixtures.article_fixture(author.id, %{title: "A Public Post", visibility: "public"})
      conn = get(conn, ~p"/channels/#{author.id}")
      assert html_response(conn, 200) =~ "A Public Post"
    end

    test "shows pinned articles on member blog", %{conn: conn} do
      author = AccountsFixtures.member_fixture()
      BlogFixtures.article_fixture(author.id, %{title: "A Pinned Post", visibility: "pinned"})
      conn = get(conn, ~p"/channels/#{author.id}")
      assert html_response(conn, 200) =~ "A Pinned Post"
    end

    test "owner sees their own private articles", %{conn: conn, member: member} do
      BlogFixtures.article_fixture(member.id, %{title: "Private Post", visibility: "private"})
      conn = get(conn, ~p"/channels/#{member.id}")
      assert html_response(conn, 200) =~ "Private Post"
    end

    test "visitor does not see another member's private articles", %{conn: conn} do
      author = AccountsFixtures.member_fixture()
      BlogFixtures.article_fixture(author.id, %{title: "Secret Post", visibility: "private"})
      conn = get(conn, ~p"/channels/#{author.id}")
      refute html_response(conn, 200) =~ "Secret Post"
    end

    test "shows blog title when member has set one", %{conn: conn} do
      author = AccountsFixtures.member_fixture()
      {:ok, author} = ZipLiner.Accounts.update_member(author, %{blog_title: "Code & Coffee"})
      conn = get(conn, ~p"/channels/#{author.id}")
      assert html_response(conn, 200) =~ "Code & Coffee"
    end

    test "shows default channel title when member has none", %{conn: conn} do
      author = AccountsFixtures.member_fixture()
      conn = get(conn, ~p"/channels/#{author.id}")
      assert html_response(conn, 200) =~ "#{author.display_name}'s Channel"
    end

    test "owner sees Write a Post button on their own blog", %{conn: conn, member: member} do
      conn = get(conn, ~p"/channels/#{member.id}")
      assert html_response(conn, 200) =~ "Write a Post"
    end

    test "visitor does not see Write a Post button on another's blog", %{conn: conn} do
      author = AccountsFixtures.member_fixture()
      conn = get(conn, ~p"/channels/#{author.id}")
      refute html_response(conn, 200) =~ "Write a Post"
    end
  end

  describe "unauthenticated access" do
    test "redirects to home when accessing index without login", %{conn: conn} do
      conn = get(conn, ~p"/channels")
      assert redirected_to(conn) == ~p"/"
    end

    test "redirects to home when accessing show without login", %{conn: conn} do
      author = AccountsFixtures.member_fixture()
      conn = get(conn, ~p"/channels/#{author.id}")
      assert redirected_to(conn) == ~p"/"
    end
  end
end
