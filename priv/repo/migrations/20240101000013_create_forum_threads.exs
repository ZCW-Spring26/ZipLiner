defmodule ZipLiner.Repo.Migrations.CreateForumThreads do
  use Ecto.Migration

  def change do
    create table(:forum_threads) do
      add :title, :string, null: false
      add :body, :text, null: false
      add :author_id, references(:members, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:forum_threads, [:author_id])
    create index(:forum_threads, [:inserted_at])
  end
end
