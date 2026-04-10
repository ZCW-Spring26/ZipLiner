defmodule ZipLiner.Repo.Migrations.CreateReplies do
  use Ecto.Migration

  def change do
    create table(:replies) do
      add :content, :text, null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :author_id, references(:members, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:replies, [:post_id])
    create index(:replies, [:author_id])
  end
end
