defmodule ZipLiner.Accounts.JoinRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending approved denied)a

  schema "join_requests" do
    field :github_id, :string
    field :github_username, :string
    field :github_avatar_url, :string
    field :display_name, :string
    field :status, Ecto.Enum, values: @statuses, default: :pending

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(join_request, attrs) do
    join_request
    |> cast(attrs, [:github_id, :github_username, :github_avatar_url, :display_name, :status])
    |> validate_required([:github_id, :github_username])
    |> validate_length(:github_username, max: 39)
    |> unique_constraint(:github_id)
  end
end
