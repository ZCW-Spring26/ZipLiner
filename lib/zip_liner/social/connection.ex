defmodule ZipLiner.Social.Connection do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending accepted)a

  schema "connections" do
    field :status, Ecto.Enum, values: @statuses, default: :pending

    belongs_to :member_a, ZipLiner.Accounts.Member, foreign_key: :member_id_a
    belongs_to :member_b, ZipLiner.Accounts.Member, foreign_key: :member_id_b

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(connection, attrs) do
    connection
    |> cast(attrs, [:member_id_a, :member_id_b, :status])
    |> validate_required([:member_id_a, :member_id_b])
    |> unique_constraint([:member_id_a, :member_id_b],
      name: :connections_member_id_a_member_id_b_index
    )
  end
end
