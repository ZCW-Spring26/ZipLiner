defmodule ZipLiner.Repo.Migrations.AddBlogTitleToMembers do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :blog_title, :string
    end
  end
end
