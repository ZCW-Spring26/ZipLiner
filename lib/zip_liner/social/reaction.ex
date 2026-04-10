defmodule ZipLiner.Social.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  @kinds ~w(thumbs_up fire lightbulb celebrate)a

  schema "reactions" do
    field :kind, Ecto.Enum, values: @kinds, default: :thumbs_up

    belongs_to :post, ZipLiner.Social.Post
    belongs_to :member, ZipLiner.Accounts.Member

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:kind, :post_id, :member_id])
    |> validate_required([:kind, :post_id, :member_id])
    |> unique_constraint([:post_id, :member_id, :kind],
      name: :reactions_post_id_member_id_kind_index
    )
  end
end
