defmodule ZipLiner.Repo.Migrations.CreateDirectMessages do
  use Ecto.Migration

  def change do
    create table(:direct_messages) do
      add :content, :text, null: false
      add :read_at, :utc_datetime
      add :sender_id, references(:members, on_delete: :delete_all), null: false
      add :recipient_id, references(:members, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:direct_messages, [:sender_id])
    create index(:direct_messages, [:recipient_id])
    create index(:direct_messages, [:inserted_at])
  end
end
