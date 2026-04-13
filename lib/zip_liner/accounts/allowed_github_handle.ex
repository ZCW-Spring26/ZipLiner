defmodule ZipLiner.Accounts.AllowedGithubHandle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "allowed_github_handles" do
    field :handle, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(allowed_handle, attrs) do
    allowed_handle
    |> cast(attrs, [:handle])
    |> validate_required([:handle])
    |> update_change(:handle, &String.downcase/1)
    |> validate_format(:handle, ~r/\A[a-z0-9][a-z0-9\-]*\z/i,
      message: "must be a valid GitHub username"
    )
    |> validate_length(:handle, max: 39)
    |> unique_constraint(:handle)
  end
end
