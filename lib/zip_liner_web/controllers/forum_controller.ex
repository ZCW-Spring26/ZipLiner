defmodule ZipLinerWeb.ForumController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Forums

  def index(conn, _params) do
    threads = Forums.list_threads()
    render(conn, :index, threads: threads)
  end

  def new(conn, _params) do
    changeset = Forums.change_thread(%ZipLiner.Forums.ForumThread{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"forum_thread" => thread_params}) do
    author_id = conn.assigns.current_member.id
    params = Map.put(thread_params, "author_id", author_id)

    case Forums.create_thread(params) do
      {:ok, thread} ->
        conn
        |> put_flash(:info, "Thread created successfully.")
        |> redirect(to: ~p"/forums/#{thread.id}")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    thread = Forums.get_thread!(id)
    comment_changeset = Forums.change_comment(%ZipLiner.Forums.ForumComment{})
    render(conn, :show, thread: thread, comment_changeset: comment_changeset)
  end

  def delete(conn, %{"id" => id}) do
    thread = Forums.get_thread!(id)

    if thread.author_id != conn.assigns.current_member.id and
         not conn.assigns.current_member.is_admin do
      conn
      |> put_flash(:error, "You can only delete your own threads.")
      |> redirect(to: ~p"/forums")
    else
      Forums.delete_thread(thread)

      conn
      |> put_flash(:info, "Thread deleted.")
      |> redirect(to: ~p"/forums")
    end
  end
end
