defmodule ZipLiner.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :tagline, :string
      add :description, :text
      add :status, :string, default: "in_progress", null: false
      add :repo_url, :string
      add :demo_url, :string
      add :tech_stack, :string, default: "[]"
      add :role, :string
      add :cohort_project, :boolean, default: false, null: false
      add :owner_id, references(:members, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:owner_id])
    create index(:projects, [:status])
  end
end
