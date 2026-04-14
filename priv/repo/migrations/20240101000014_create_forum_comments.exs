defmodule ZipLiner.Repo.Migrations.CreateForumComments do
  use Ecto.Migration

  def change do
    create table(:forum_comments) do
      add :body, :text, null: false
      add :thread_id, references(:forum_threads, on_delete: :delete_all), null: false
      add :author_id, references(:members, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:forum_comments, [:thread_id])
    create index(:forum_comments, [:author_id])
  end
end
