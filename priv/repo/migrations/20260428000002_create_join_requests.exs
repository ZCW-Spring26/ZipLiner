defmodule ZipLiner.Repo.Migrations.CreateJoinRequests do
  use Ecto.Migration

  def change do
    create table(:join_requests) do
      add :github_id, :string, null: false
      add :github_username, :string, null: false
      add :github_avatar_url, :string
      add :display_name, :string
      add :status, :string, null: false, default: "pending"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:join_requests, [:github_id])
    create index(:join_requests, [:github_username])
    create index(:join_requests, [:status])
  end
end
