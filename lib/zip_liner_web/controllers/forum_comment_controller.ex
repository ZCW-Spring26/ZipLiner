defmodule ZipLinerWeb.ForumCommentController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Forums

  def create(conn, %{"forum_id" => thread_id, "forum_comment" => comment_params}) do
    author_id = conn.assigns.current_member.id
    params = Map.merge(comment_params, %{"thread_id" => thread_id, "author_id" => author_id})

    case Forums.create_comment(params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment added.")
        |> redirect(to: ~p"/forums/#{thread_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not add comment.")
        |> redirect(to: ~p"/forums/#{thread_id}")
    end
  end

  def update(conn, %{"forum_id" => thread_id, "id" => comment_id, "forum_comment" => comment_params}) do
    comment = Forums.get_comment!(comment_id)

    if comment.author_id != conn.assigns.current_member.id and
         not conn.assigns.current_member.is_admin do
      conn
      |> put_flash(:error, "You can only edit your own comments.")
      |> redirect(to: ~p"/forums/#{thread_id}")
    else
      case Forums.update_comment(comment, comment_params) do
        {:ok, _comment} ->
          conn
          |> put_flash(:info, "Comment updated.")
          |> redirect(to: ~p"/forums/#{thread_id}#comment-#{comment_id}")

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Could not update comment.")
          |> redirect(to: ~p"/forums/#{thread_id}#comment-#{comment_id}")
      end
    end
  end

  def delete(conn, %{"forum_id" => thread_id, "id" => comment_id}) do
    comment = Forums.get_comment!(comment_id)

    if comment.author_id != conn.assigns.current_member.id and
         not conn.assigns.current_member.is_admin do
      conn
      |> put_flash(:error, "You can only delete your own comments.")
      |> redirect(to: ~p"/forums/#{thread_id}")
    else
      Forums.delete_comment(comment)

      conn
      |> put_flash(:info, "Comment deleted.")
      |> redirect(to: ~p"/forums/#{thread_id}")
    end
  end
end
