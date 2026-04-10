defmodule ZipLinerWeb.PostController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Social

  def create(conn, %{"post" => post_params}) do
    author_id = conn.assigns.current_member.id
    params = Map.put(post_params, "author_id", author_id)

    case Social.create_post(params) do
      {:ok, post} ->
        post = ZipLiner.Repo.preload(post, :author)

        if get_req_header(conn, "hx-request") != [] do
          render(conn, :post_card, post: post)
        else
          conn
          |> put_flash(:info, "Post created.")
          |> redirect(to: ~p"/feed")
        end

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not create post.")
        |> redirect(to: ~p"/feed")
    end
  end

  def show(conn, %{"id" => id}) do
    post = Social.get_post!(id)
    replies = Social.list_replies(id)

    if get_req_header(conn, "hx-request") != [] do
      render(conn, :replies, post: post, replies: replies)
    else
      render(conn, :show, post: post, replies: replies)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Social.get_post!(id)

    if post.author_id != conn.assigns.current_member.id do
      conn
      |> put_flash(:error, "You can only delete your own posts.")
      |> redirect(to: ~p"/feed")
    else
      ZipLiner.Repo.delete!(post)

      if get_req_header(conn, "hx-request") != [] do
        send_resp(conn, 200, "")
      else
        conn
        |> put_flash(:info, "Post deleted.")
        |> redirect(to: ~p"/feed")
      end
    end
  end

  def react(conn, %{"id" => id, "kind" => kind}) do
    member_id = conn.assigns.current_member.id
    Social.add_reaction(String.to_integer(id), member_id, String.to_atom(kind))

    post = Social.get_post!(id) |> ZipLiner.Repo.preload(:author)

    if get_req_header(conn, "hx-request") != [] do
      render(conn, :post_card, post: post)
    else
      redirect(conn, to: ~p"/feed")
    end
  end

  def reply(conn, %{"id" => id, "reply" => reply_params}) do
    author_id = conn.assigns.current_member.id
    params = Map.merge(reply_params, %{"post_id" => id, "author_id" => author_id})

    case Social.create_reply(params) do
      {:ok, _reply} ->
        replies = Social.list_replies(id)
        post = Social.get_post!(id)

        if get_req_header(conn, "hx-request") != [] do
          render(conn, :replies, post: post, replies: replies)
        else
          redirect(conn, to: ~p"/feed")
        end

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not post reply.")
        |> redirect(to: ~p"/feed")
    end
  end
end
