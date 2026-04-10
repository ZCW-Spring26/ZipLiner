defmodule ZipLiner.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :description, :string
      add :cohort_id, references(:cohorts, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:channels, [:name])
    create index(:channels, [:type])
    create index(:channels, [:cohort_id])
  end
end
