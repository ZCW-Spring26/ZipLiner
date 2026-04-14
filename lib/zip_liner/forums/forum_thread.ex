defmodule ZipLiner.Forums.ForumThread do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forum_threads" do
    field :title, :string
    field :body, :string

    belongs_to :author, ZipLiner.Accounts.Member, foreign_key: :author_id
    has_many :comments, ZipLiner.Forums.ForumComment, foreign_key: :thread_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:title, :body, :author_id])
    |> validate_required([:title, :body, :author_id])
    |> validate_length(:title, max: 200)
    |> validate_length(:body, max: 10_000)
  end
end
