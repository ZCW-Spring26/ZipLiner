defmodule ZipLiner.Social.DirectMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "direct_messages" do
    field :content, :string
    field :read_at, :utc_datetime

    belongs_to :sender, ZipLiner.Accounts.Member, foreign_key: :sender_id
    belongs_to :recipient, ZipLiner.Accounts.Member, foreign_key: :recipient_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dm, attrs) do
    dm
    |> cast(attrs, [:content, :sender_id, :recipient_id, :read_at])
    |> validate_required([:content, :sender_id, :recipient_id])
    |> validate_length(:content, max: 5000)
  end
end
