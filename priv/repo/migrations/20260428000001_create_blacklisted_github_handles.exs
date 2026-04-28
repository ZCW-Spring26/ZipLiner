defmodule ZipLiner.Repo.Migrations.CreateBlacklistedGithubHandles do
  use Ecto.Migration

  def change do
    create table(:blacklisted_github_handles) do
      add :handle, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:blacklisted_github_handles, [:handle])
  end
end
