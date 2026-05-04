defmodule ZipLiner.Repo.Migrations.AddSlackHandleToMembers do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :slack_handle, :string
    end
  end
end
