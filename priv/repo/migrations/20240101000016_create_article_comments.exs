defmodule ZipLiner.Repo.Migrations.CreateArticleComments do
  use Ecto.Migration

  def change do
    create table(:article_comments) do
      add :body, :text, null: false
      add :article_id, references(:articles, on_delete: :delete_all), null: false
      add :author_id, references(:members, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:article_comments, [:article_id])
    create index(:article_comments, [:author_id])
  end
end
