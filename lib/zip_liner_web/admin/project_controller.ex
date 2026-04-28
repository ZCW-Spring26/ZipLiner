defmodule ZipLinerWeb.Admin.ProjectController do
  use ZipLinerWeb, :controller

  plug ZipLinerWeb.Plugs.RequireAdmin

  alias ZipLiner.Projects
  alias ZipLiner.Projects.Project
  alias ZipLiner.Accounts

  def index(conn, _params) do
    projects = Projects.list_projects()
    render(conn, :index, projects: projects)
  end

  def new(conn, _params) do
    changeset = Projects.change_project(%Project{})
    members = Accounts.list_members()
    render(conn, :new, changeset: changeset, members: members)
  end

  def create(conn, %{"project" => project_params}) do
    case Projects.create_project(project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project created.")
        |> redirect(to: ~p"/admin/projects/#{project.id}")

      {:error, changeset} ->
        members = Accounts.list_members()
        render(conn, :new, changeset: changeset, members: members)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    render(conn, :show, project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    changeset = Projects.change_project(project)
    members = Accounts.list_members()
    render(conn, :edit, project: project, changeset: changeset, members: members)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    case Projects.update_project(project, project_params) do
      {:ok, updated_project} ->
        conn
        |> put_flash(:info, "Project updated.")
        |> redirect(to: ~p"/admin/projects/#{updated_project.id}")

      {:error, changeset} ->
        members = Accounts.list_members()
        render(conn, :edit, project: project, changeset: changeset, members: members)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted.")
    |> redirect(to: ~p"/admin/projects")
  end
end
