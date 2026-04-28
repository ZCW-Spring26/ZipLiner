defmodule ZipLinerWeb.ArticleController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Blog

  # ---------------------------------------------------------------------------
  # Public show — accessible without authentication for public articles
  # ---------------------------------------------------------------------------

  def show(conn, %{"id" => id}) do
    article = Blog.get_article!(id)

    cond do
      article.visibility == :public ->
        comment_changeset = Blog.change_comment(%ZipLiner.Blog.ArticleComment{})
        render(conn, :show, article: article, comment_changeset: comment_changeset)

      conn.assigns[:current_member] != nil ->
        comment_changeset = Blog.change_comment(%ZipLiner.Blog.ArticleComment{})
        render(conn, :show, article: article, comment_changeset: comment_changeset)

      true ->
        conn
        |> put_flash(:error, "You must be signed in to view that article.")
        |> redirect(to: ~p"/")
    end
  end

  # ---------------------------------------------------------------------------
  # Authenticated actions
  # ---------------------------------------------------------------------------

  def index(conn, _params) do
    articles = Blog.list_articles()
    render(conn, :index, articles: articles)
  end

  def new(conn, _params) do
    changeset = Blog.change_article(%ZipLiner.Blog.Article{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"article" => article_params}) do
    author_id = conn.assigns.current_member.id
    params = Map.put(article_params, "author_id", author_id)

    case Blog.create_article(params) do
      {:ok, article} ->
        conn
        |> put_flash(:info, "Article published successfully.")
        |> redirect(to: ~p"/articles/#{article.id}")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    article = Blog.get_article!(id)

    if article.author_id != conn.assigns.current_member.id and
         not conn.assigns.current_member.is_admin do
      conn
      |> put_flash(:error, "You can only delete your own articles.")
      |> redirect(to: ~p"/articles")
    else
      Blog.delete_article(article)

      conn
      |> put_flash(:info, "Article deleted.")
      |> redirect(to: ~p"/articles")
    end
  end
end
