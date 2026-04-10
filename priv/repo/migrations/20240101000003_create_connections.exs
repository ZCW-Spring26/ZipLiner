defmodule ZipLiner.Repo.Migrations.CreateConnections do
  use Ecto.Migration

  def change do
    create table(:connections) do
      add :member_id_a, references(:members, on_delete: :delete_all), null: false
      add :member_id_b, references(:members, on_delete: :delete_all), null: false
      add :status, :string, default: "pending", null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:connections, [:member_id_a, :member_id_b])
    create index(:connections, [:member_id_b])
    create index(:connections, [:status])
  end
end
