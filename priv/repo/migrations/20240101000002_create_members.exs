defmodule ZipLiner.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :github_id, :string, null: false
      add :github_username, :string, null: false
      add :github_avatar_url, :string
      add :linkedin_id, :string
      add :linkedin_url, :string
      add :display_name, :string, null: false
      add :bio, :string, size: 280
      add :current_title, :string
      add :employer, :string
      add :location, :string
      add :role, :string, default: "student", null: false
      add :status, :string, default: "active", null: false
      add :open_to_opportunities, :boolean, default: false, null: false
      add :skills, :string, default: "[]"
      add :avatar_source, :string, default: "github"
      add :cohort_id, references(:cohorts, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:members, [:github_id])
    create unique_index(:members, [:github_username])
    create index(:members, [:cohort_id])
    create index(:members, [:status])
  end
end
