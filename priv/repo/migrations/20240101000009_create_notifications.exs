defmodule ZipLiner.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :type, :string, null: false
      add :payload, :string, default: "{}"
      add :read_at, :utc_datetime
      add :recipient_id, references(:members, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:recipient_id])
    create index(:notifications, [:read_at])
  end
end
