defmodule ZipLiner.Forums do
  @moduledoc """
  The Forums context manages forum threads and comments, including
  @handle mention notifications.
  """

  import Ecto.Query, warn: false
  alias ZipLiner.Repo
  alias ZipLiner.Forums.{ForumThread, ForumComment}
  alias ZipLiner.Accounts
  alias ZipLiner.Notifications.Notification

  # ---------------------------------------------------------------------------
  # Forum Threads
  # ---------------------------------------------------------------------------

  @doc "Returns all forum threads, newest first."
  def list_threads do
    ForumThread
    |> order_by([t], desc: t.inserted_at)
    |> preload([:author, :comments])
    |> Repo.all()
  end

  @doc "Gets a single forum thread with author and comments (with authors) preloaded. Raises if not found."
  def get_thread!(id) do
    ForumThread
    |> preload([:author, comments: :author])
    |> Repo.get!(id)
  end

  @doc "Creates a forum thread and fires mention notifications."
  def create_thread(attrs \\ %{}) do
    result =
      %ForumThread{}
      |> ForumThread.changeset(attrs)
      |> Repo.insert()

    with {:ok, thread} <- result do
      notify_mentions(thread.body, thread.author_id, %{
        type: :mention,
        payload: %{
          "context" => "forum_thread",
          "thread_id" => thread.id,
          "thread_title" => thread.title
        }
      })

      {:ok, thread}
    end
  end

  @doc "Returns a changeset for a forum thread."
  def change_thread(%ForumThread{} = thread, attrs \\ %{}) do
    ForumThread.changeset(thread, attrs)
  end

  @doc "Deletes a forum thread."
  def delete_thread(%ForumThread{} = thread) do
    Repo.delete(thread)
  end

  # ---------------------------------------------------------------------------
  # Forum Comments
  # ---------------------------------------------------------------------------

  @doc "Creates a forum comment and fires mention notifications."
  def create_comment(attrs \\ %{}) do
    result =
      %ForumComment{}
      |> ForumComment.changeset(attrs)
      |> Repo.insert()

    with {:ok, comment} <- result do
      thread = get_thread!(comment.thread_id)

      notify_mentions(comment.body, comment.author_id, %{
        type: :mention,
        payload: %{
          "context" => "forum_comment",
          "thread_id" => thread.id,
          "thread_title" => thread.title
        }
      })

      {:ok, comment}
    end
  end

  @doc "Returns a changeset for a forum comment."
  def change_comment(%ForumComment{} = comment, attrs \\ %{}) do
    ForumComment.changeset(comment, attrs)
  end

  @doc "Gets a single forum comment. Raises if not found."
  def get_comment!(id), do: Repo.get!(ForumComment, id)

  @doc "Deletes a forum comment."
  def delete_comment(%ForumComment{} = comment) do
    Repo.delete(comment)
  end

  # ---------------------------------------------------------------------------
  # Mention helpers
  # ---------------------------------------------------------------------------

  @mention_regex ~r/@([A-Za-z0-9_-]+)/

  @doc """
  Extracts all @handle mentions from `text`, looks up matching members,
  and creates a mention notification for each (excluding the author themselves).
  """
  def notify_mentions(text, author_id, notification_attrs) when is_binary(text) do
    @mention_regex
    |> Regex.scan(text, capture: :all_but_first)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.each(fn handle ->
      case Accounts.get_member_by_github_username(handle) do
        nil ->
          :ok

        member when member.id == author_id ->
          :ok

        member ->
          %Notification{}
          |> Notification.changeset(
            Map.merge(notification_attrs, %{recipient_id: member.id})
          )
          |> Repo.insert()
      end
    end)
  end

  def notify_mentions(_text, _author_id, _attrs), do: :ok
end
