defmodule ZipLiner.Forums.ForumComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forum_comments" do
    field :body, :string

    belongs_to :thread, ZipLiner.Forums.ForumThread, foreign_key: :thread_id
    belongs_to :author, ZipLiner.Accounts.Member, foreign_key: :author_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :thread_id, :author_id])
    |> validate_required([:body, :thread_id, :author_id])
    |> validate_length(:body, max: 5_000)
  end
end
