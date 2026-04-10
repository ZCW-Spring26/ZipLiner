defmodule ZipLinerWeb.ProjectController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Projects
  alias ZipLiner.Projects.Project

  def index(conn, params) do
    projects =
      case params do
        %{"owner_id" => owner_id} -> Projects.list_projects_for_member(owner_id)
        _ -> Projects.list_projects()
      end

    render(conn, :index, projects: projects)
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    render(conn, :show, project: project)
  end

  def new(conn, _params) do
    changeset = Projects.change_project(%Project{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    params = Map.put(project_params, "owner_id", conn.assigns.current_member.id)

    case Projects.create_project(params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: ~p"/projects/#{project.id}")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    project = Projects.get_project!(id)

    if project.owner_id != conn.assigns.current_member.id do
      conn
      |> put_flash(:error, "You can only edit your own projects.")
      |> redirect(to: ~p"/projects/#{project.id}")
    else
      changeset = Projects.change_project(project)
      render(conn, :edit, project: project, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    if project.owner_id != conn.assigns.current_member.id do
      conn
      |> put_flash(:error, "You can only edit your own projects.")
      |> redirect(to: ~p"/projects/#{project.id}")
    else
      case Projects.update_project(project, project_params) do
        {:ok, updated_project} ->
          conn
          |> put_flash(:info, "Project updated.")
          |> redirect(to: ~p"/projects/#{updated_project.id}")

        {:error, changeset} ->
          render(conn, :edit, project: project, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)

    if project.owner_id != conn.assigns.current_member.id do
      conn
      |> put_flash(:error, "You can only delete your own projects.")
      |> redirect(to: ~p"/projects")
    else
      Projects.delete_project(project)

      conn
      |> put_flash(:info, "Project deleted.")
      |> redirect(to: ~p"/projects")
    end
  end
end
