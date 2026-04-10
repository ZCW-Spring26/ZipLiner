defmodule ZipLiner.Projects do
  @moduledoc """
  The Projects context manages member projects (Project Showcase).
  """

  import Ecto.Query, warn: false
  alias ZipLiner.Repo
  alias ZipLiner.Projects.Project

  @doc "Returns all projects."
  def list_projects do
    Project
    |> order_by([p], desc: p.inserted_at)
    |> preload(:owner)
    |> Repo.all()
  end

  @doc "Returns all projects for a given member."
  def list_projects_for_member(member_id) do
    Project
    |> where([p], p.owner_id == ^member_id)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @doc "Gets a single project. Raises if not found."
  def get_project!(id) do
    Project
    |> preload(:owner)
    |> Repo.get!(id)
  end

  @doc "Creates a project."
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a project."
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a project."
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc "Returns a changeset for a project."
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end
end
