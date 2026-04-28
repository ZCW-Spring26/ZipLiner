defmodule ZipLiner.Blog.ArticleComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_comments" do
    field :body, :string

    belongs_to :article, ZipLiner.Blog.Article
    belongs_to :author, ZipLiner.Accounts.Member, foreign_key: :author_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :article_id, :author_id])
    |> validate_required([:body, :article_id, :author_id])
    |> validate_length(:body, max: 5_000)
  end
end
