defmodule ZipLiner.Blog.Article do
  use Ecto.Schema
  import Ecto.Changeset

  @visibilities ~w(private public pinned)a

  schema "articles" do
    field :title, :string
    field :body, :string
    field :visibility, Ecto.Enum, values: @visibilities, default: :private

    belongs_to :author, ZipLiner.Accounts.Member, foreign_key: :author_id
    has_many :comments, ZipLiner.Blog.ArticleComment, foreign_key: :article_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :body, :visibility, :author_id])
    |> validate_required([:title, :body, :author_id])
    |> validate_length(:title, max: 200)
    |> validate_length(:body, max: 50_000)
    |> validate_inclusion(:visibility, @visibilities)
  end
end
