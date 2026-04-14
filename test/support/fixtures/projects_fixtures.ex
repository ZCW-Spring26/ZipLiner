defmodule ZipLiner.ProjectsFixtures do
  @moduledoc """
  Test fixtures for the Projects context.
  """

  alias ZipLiner.Projects

  def project_attrs(owner_id, attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "Test Project #{System.unique_integer([:positive])}",
      owner_id: owner_id,
      status: "in_progress"
    })
  end

  def project_fixture(owner_id, attrs \\ %{}) do
    {:ok, project} =
      owner_id
      |> project_attrs(attrs)
      |> Projects.create_project()

    project
  end
end
