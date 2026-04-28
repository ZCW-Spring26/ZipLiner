defmodule ZipLinerWeb.ArticleCommentController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Blog

  def create(conn, %{"article_id" => article_id, "article_comment" => comment_params}) do
    author_id = conn.assigns.current_member.id
    params = Map.merge(comment_params, %{"article_id" => article_id, "author_id" => author_id})

    case Blog.create_comment(params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment added.")
        |> redirect(to: ~p"/articles/#{article_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not add comment.")
        |> redirect(to: ~p"/articles/#{article_id}")
    end
  end

  def delete(conn, %{"article_id" => article_id, "id" => comment_id}) do
    comment = Blog.get_comment!(comment_id)

    if comment.author_id != conn.assigns.current_member.id and
         not conn.assigns.current_member.is_admin do
      conn
      |> put_flash(:error, "You can only delete your own comments.")
      |> redirect(to: ~p"/articles/#{article_id}")
    else
      Blog.delete_comment(comment)

      conn
      |> put_flash(:info, "Comment deleted.")
      |> redirect(to: ~p"/articles/#{article_id}")
    end
  end
end
