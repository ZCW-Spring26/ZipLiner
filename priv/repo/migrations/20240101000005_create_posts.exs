defmodule ZipLiner.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :type, :string, default: "status", null: false
      add :content, :text, null: false
      add :url, :string
      add :url_title, :string
      add :author_id, references(:members, on_delete: :delete_all), null: false
      add :channel_id, references(:channels, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:posts, [:author_id])
    create index(:posts, [:channel_id])
    create index(:posts, [:inserted_at])
  end
end
