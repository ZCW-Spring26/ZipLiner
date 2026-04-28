defmodule ZipLiner.Blog do
  @moduledoc """
  The Blog context manages long-form personal articles and their comments.

  Articles can be `private` (visible only to authenticated ZipLiner members) or
  `public` (visible to anyone who has the direct link).
  """

  import Ecto.Query, warn: false
  alias ZipLiner.Repo
  alias ZipLiner.Blog.{Article, ArticleComment}
  alias ZipLiner.Accounts
  alias ZipLiner.Notifications.Notification

  # ---------------------------------------------------------------------------
  # Articles
  # ---------------------------------------------------------------------------

  @doc "Returns all articles visible to any authenticated member, newest first."
  def list_articles do
    Article
    |> order_by([a], desc: a.inserted_at)
    |> preload([:author, :comments])
    |> Repo.all()
  end

  @doc "Returns all articles by a given author, newest first."
  def list_articles_by_author(author_id) do
    Article
    |> where([a], a.author_id == ^author_id)
    |> order_by([a], desc: a.inserted_at)
    |> preload([:author, :comments])
    |> Repo.all()
  end

  @doc "Returns all public articles, newest first."
  def list_public_articles do
    Article
    |> where([a], a.visibility == :public)
    |> order_by([a], desc: a.inserted_at)
    |> preload([:author, :comments])
    |> Repo.all()
  end

  @doc "Gets a single article with author and comments (with authors) preloaded. Raises if not found."
  def get_article!(id) do
    Article
    |> preload([:author, comments: :author])
    |> Repo.get!(id)
  end

  @doc "Creates an article and fires mention notifications."
  def create_article(attrs \\ %{}) do
    result =
      %Article{}
      |> Article.changeset(attrs)
      |> Repo.insert()

    with {:ok, article} <- result do
      notify_mentions(article.body, article.author_id, %{
        type: :mention,
        payload: %{
          "context" => "article",
          "article_id" => article.id,
          "article_title" => article.title
        }
      })

      {:ok, article}
    end
  end

  @doc "Returns a changeset for an article."
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  @doc "Deletes an article."
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  # ---------------------------------------------------------------------------
  # Article Comments
  # ---------------------------------------------------------------------------

  @doc "Creates an article comment and fires mention notifications."
  def create_comment(attrs \\ %{}) do
    result =
      %ArticleComment{}
      |> ArticleComment.changeset(attrs)
      |> Repo.insert()

    with {:ok, comment} <- result do
      article = get_article!(comment.article_id)

      notify_mentions(comment.body, comment.author_id, %{
        type: :mention,
        payload: %{
          "context" => "article_comment",
          "article_id" => article.id,
          "article_title" => article.title
        }
      })

      {:ok, comment}
    end
  end

  @doc "Returns a changeset for an article comment."
  def change_comment(%ArticleComment{} = comment, attrs \\ %{}) do
    ArticleComment.changeset(comment, attrs)
  end

  @doc "Gets a single article comment. Raises if not found."
  def get_comment!(id), do: Repo.get!(ArticleComment, id)

  @doc "Deletes an article comment."
  def delete_comment(%ArticleComment{} = comment) do
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
