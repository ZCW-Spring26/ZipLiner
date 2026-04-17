defmodule ZipLiner.Repo.Migrations.AddThemePreferenceToMembers do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :theme_preference, :string, default: "light", null: false
    end
  end
end
