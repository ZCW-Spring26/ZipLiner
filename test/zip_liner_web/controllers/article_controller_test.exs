defmodule ZipLinerWeb.ArticleControllerTest do
  use ZipLinerWeb.ConnCase

  alias ZipLiner.AccountsFixtures
  alias ZipLiner.BlogFixtures

  describe "index" do
    setup :log_in_member

    test "lists all articles", %{conn: conn} do
      conn = get(conn, ~p"/articles")
      assert html_response(conn, 200) =~ "Articles"
    end

    test "shows article in listing", %{conn: conn, member: member} do
      BlogFixtures.article_fixture(member.id, %{title: "My Long-Form Article"})
      conn = get(conn, ~p"/articles")
      assert html_response(conn, 200) =~ "My Long-Form Article"
    end

    test "shows pinned badge for pinned articles", %{conn: conn, member: member} do
      BlogFixtures.article_fixture(member.id, %{title: "Featured Post", visibility: "pinned"})
      conn = get(conn, ~p"/articles")
      assert html_response(conn, 200) =~ "Featured Post"
      assert html_response(conn, 200) =~ "Pinned"
    end
  end

  describe "new" do
    setup :log_in_member

    test "renders new article form", %{conn: conn} do
      conn = get(conn, ~p"/articles/new")
      assert html_response(conn, 200) =~ "Write an Article"
    end
  end

  describe "create" do
    setup :log_in_member

    test "creates article and redirects to show", %{conn: conn} do
      conn =
        post(conn, ~p"/articles", %{
          "article" => %{
            "title" => "New Article Title",
            "body" => "Article body content",
            "visibility" => "private"
          }
        })

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/articles/#{id}"
    end

    test "creates a public article", %{conn: conn} do
      conn =
        post(conn, ~p"/articles", %{
          "article" => %{
            "title" => "Public Article",
            "body" => "Public body content",
            "visibility" => "public"
          }
        })

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/articles/#{id}"
    end

    test "creates a pinned article", %{conn: conn} do
      conn =
        post(conn, ~p"/articles", %{
          "article" => %{
            "title" => "Pinned Article",
            "body" => "Pinned body content",
            "visibility" => "pinned"
          }
        })

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/articles/#{id}"
    end

    test "renders errors when title is missing", %{conn: conn} do
      conn =
        post(conn, ~p"/articles", %{
          "article" => %{"title" => "", "body" => "Some body", "visibility" => "private"}
        })

      assert html_response(conn, 200) =~ "Write an Article"
    end
  end

  describe "show — authenticated access" do
    setup :log_in_member

    test "shows private article to authenticated member", %{conn: conn, member: member} do
      article = BlogFixtures.article_fixture(member.id, %{title: "Private Post", body: "Secret content", visibility: "private"})
      conn = get(conn, ~p"/articles/#{article.id}")
      assert html_response(conn, 200) =~ "Private Post"
      assert html_response(conn, 200) =~ "Secret content"
    end

    test "shows public article to authenticated member", %{conn: conn, member: member} do
      article = BlogFixtures.article_fixture(member.id, %{title: "Public Post", body: "Open content", visibility: "public"})
      conn = get(conn, ~p"/articles/#{article.id}")
      assert html_response(conn, 200) =~ "Public Post"
    end

    test "shows add comment form to authenticated member", %{conn: conn, member: member} do
      article = BlogFixtures.article_fixture(member.id)
      conn = get(conn, ~p"/articles/#{article.id}")
      assert html_response(conn, 200) =~ "Add a Comment"
    end

    test "owner sees delete button", %{conn: conn, member: member} do
      article = BlogFixtures.article_fixture(member.id)
      conn = get(conn, ~p"/articles/#{article.id}")
      assert html_response(conn, 200) =~ "Delete"
    end

    test "non-owner does not see delete button", %{conn: conn} do
      other = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(other.id)
      conn = get(conn, ~p"/articles/#{article.id}")
      refute html_response(conn, 200) =~ "Delete"
    end

    test "owner sees edit button", %{conn: conn, member: member} do
      article = BlogFixtures.article_fixture(member.id)
      conn = get(conn, ~p"/articles/#{article.id}")
      assert html_response(conn, 200) =~ "Edit"
    end

    test "non-owner does not see edit button", %{conn: conn} do
      other = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(other.id)
      conn = get(conn, ~p"/articles/#{article.id}")
      refute html_response(conn, 200) =~ "Edit"
    end
  end

  describe "show — unauthenticated access" do
    test "shows public article to unauthenticated visitor", %{conn: conn} do
      member = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(member.id, %{title: "Open Article", visibility: "public"})
      conn = get(conn, ~p"/articles/#{article.id}")
      assert html_response(conn, 200) =~ "Open Article"
    end

    test "shows pinned article to unauthenticated visitor", %{conn: conn} do
      member = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(member.id, %{title: "Pinned Article", visibility: "pinned"})
      conn = get(conn, ~p"/articles/#{article.id}")
      assert html_response(conn, 200) =~ "Pinned Article"
    end

    test "redirects unauthenticated visitor away from private article", %{conn: conn} do
      member = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(member.id, %{visibility: "private"})
      conn = get(conn, ~p"/articles/#{article.id}")
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "signed in"
    end

    test "does not show comment form to unauthenticated visitor", %{conn: conn} do
      member = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(member.id, %{visibility: "public"})
      conn = get(conn, ~p"/articles/#{article.id}")
      refute html_response(conn, 200) =~ "Add a Comment"
    end
  end

  describe "edit" do
    setup :log_in_member

    test "renders edit form for owner", %{conn: conn, member: member} do
      article = BlogFixtures.article_fixture(member.id, %{title: "My Article"})
      conn = get(conn, ~p"/articles/#{article.id}/edit")
      assert html_response(conn, 200) =~ "Edit Article"
      assert html_response(conn, 200) =~ "My Article"
    end

    test "redirects non-owner away from edit", %{conn: conn} do
      other = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(other.id)
      conn = get(conn, ~p"/articles/#{article.id}/edit")
      assert redirected_to(conn) == ~p"/articles/#{article.id}"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "only edit your own"
    end

    test "admin can edit any article", %{conn: conn} do
      admin = AccountsFixtures.member_fixture(%{is_admin: true})
      other = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(other.id)

      conn = log_in_member(conn, admin)
      conn = get(conn, ~p"/articles/#{article.id}/edit")
      assert html_response(conn, 200) =~ "Edit Article"
    end
  end

  describe "update" do
    setup :log_in_member

    test "owner can update article", %{conn: conn, member: member} do
      article = BlogFixtures.article_fixture(member.id)

      conn =
        patch(conn, ~p"/articles/#{article.id}", %{
          "article" => %{"title" => "Updated Title", "body" => "Updated body", "visibility" => "private"}
        })

      assert redirected_to(conn) == ~p"/articles/#{article.id}"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "updated"
    end

    test "non-owner cannot update article", %{conn: conn} do
      other = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(other.id)

      conn =
        patch(conn, ~p"/articles/#{article.id}", %{
          "article" => %{"title" => "Hijacked", "body" => "Hijacked body", "visibility" => "private"}
        })

      assert redirected_to(conn) == ~p"/articles/#{article.id}"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "only edit your own"
    end

    test "admin can update any article", %{conn: conn} do
      admin = AccountsFixtures.member_fixture(%{is_admin: true})
      other = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(other.id)

      conn = log_in_member(conn, admin)

      conn =
        patch(conn, ~p"/articles/#{article.id}", %{
          "article" => %{"title" => "Admin Updated", "body" => "Admin body", "visibility" => "private"}
        })

      assert redirected_to(conn) == ~p"/articles/#{article.id}"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "updated"
    end

    test "renders errors when title is blank", %{conn: conn, member: member} do
      article = BlogFixtures.article_fixture(member.id)

      conn =
        patch(conn, ~p"/articles/#{article.id}", %{
          "article" => %{"title" => "", "body" => "Some body", "visibility" => "private"}
        })

      assert html_response(conn, 200) =~ "Edit Article"
    end
  end

  describe "delete" do
    setup :log_in_member

    test "owner can delete article", %{conn: conn, member: member} do
      article = BlogFixtures.article_fixture(member.id)
      conn = delete(conn, ~p"/articles/#{article.id}")
      assert redirected_to(conn) == ~p"/articles"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "deleted"
    end

    test "non-owner cannot delete article", %{conn: conn} do
      other = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(other.id)
      conn = delete(conn, ~p"/articles/#{article.id}")
      assert redirected_to(conn) == ~p"/articles"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "only delete your own"
    end

    test "admin can delete any article", %{conn: conn} do
      admin = AccountsFixtures.member_fixture(%{is_admin: true})
      other = AccountsFixtures.member_fixture()
      article = BlogFixtures.article_fixture(other.id)

      conn = log_in_member(conn, admin)
      conn = delete(conn, ~p"/articles/#{article.id}")
      assert redirected_to(conn) == ~p"/articles"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "deleted"
    end
  end

  describe "unauthenticated access to authenticated routes" do
    test "redirects to home when accessing index without login", %{conn: conn} do
      conn = get(conn, ~p"/articles")
      assert redirected_to(conn) == ~p"/"
    end

    test "redirects to home when accessing new without login", %{conn: conn} do
      conn = get(conn, ~p"/articles/new")
      assert redirected_to(conn) == ~p"/"
    end
  end
end
