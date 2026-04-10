defmodule ZipLiner.Repo.Migrations.CreateCohorts do
  use Ecto.Migration

  def change do
    create table(:cohorts) do
      add :name, :string, null: false
      add :start_date, :date, null: false
      add :graduation_date, :date

      timestamps(type: :utc_datetime)
    end

    create unique_index(:cohorts, [:name])
  end
end
