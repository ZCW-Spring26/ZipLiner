defmodule ZipLiner.Repo.Migrations.AddIsAdminToMembers do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :is_admin, :boolean, default: false, null: false
    end
  end
end
