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

  def edit(conn, %{"id" => id}) do
    thread = Forums.get_thread!(id)

    if authorized_for_thread?(conn, thread) do
      changeset = Forums.change_thread(thread)
      render(conn, :edit, thread: thread, changeset: changeset)
    else
      conn
      |> put_flash(:error, "You can only edit your own threads.")
      |> redirect(to: ~p"/forums/#{id}")
    end
  end

  def update(conn, %{"id" => id, "forum_thread" => thread_params}) do
    thread = Forums.get_thread!(id)

    if authorized_for_thread?(conn, thread) do
      case Forums.update_thread(thread, thread_params) do
        {:ok, updated_thread} ->
          conn
          |> put_flash(:info, "Thread updated successfully.")
          |> redirect(to: ~p"/forums/#{updated_thread.id}")

        {:error, changeset} ->
          render(conn, :edit, thread: thread, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "You can only edit your own threads.")
      |> redirect(to: ~p"/forums/#{id}")
    end
  end

  def delete(conn, %{"id" => id}) do
    thread = Forums.get_thread!(id)

    if authorized_for_thread?(conn, thread) do
      Forums.delete_thread(thread)

      conn
      |> put_flash(:info, "Thread deleted.")
      |> redirect(to: ~p"/forums")
    else
      conn
      |> put_flash(:error, "You can only delete your own threads.")
      |> redirect(to: ~p"/forums")
    end
  end

  defp authorized_for_thread?(conn, thread) do
    conn.assigns.current_member.id == thread.author_id or conn.assigns.current_member.is_admin
  end
end
