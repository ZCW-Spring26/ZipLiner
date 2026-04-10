defmodule ZipLiner.Social.Reply do
  use Ecto.Schema
  import Ecto.Changeset

  schema "replies" do
    field :content, :string

    belongs_to :post, ZipLiner.Social.Post
    belongs_to :author, ZipLiner.Accounts.Member, foreign_key: :author_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reply, attrs) do
    reply
    |> cast(attrs, [:content, :post_id, :author_id])
    |> validate_required([:content, :post_id, :author_id])
    |> validate_length(:content, max: 1000)
  end
end
