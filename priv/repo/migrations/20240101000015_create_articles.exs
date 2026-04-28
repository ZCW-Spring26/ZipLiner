defmodule ZipLiner.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string, null: false
      add :body, :text, null: false
      add :visibility, :string, default: "private", null: false
      add :author_id, references(:members, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:articles, [:author_id])
    create index(:articles, [:visibility])
    create index(:articles, [:inserted_at])
  end
end
