defmodule ZipLiner.Repo.Migrations.CreateAllowedGithubHandles do
  use Ecto.Migration

  def change do
    create table(:allowed_github_handles) do
      add :handle, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:allowed_github_handles, [:handle])
  end
end
