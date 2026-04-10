defmodule ZipLiner.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add :kind, :string, null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :member_id, references(:members, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:reactions, [:post_id, :member_id, :kind])
    create index(:reactions, [:member_id])
  end
end
