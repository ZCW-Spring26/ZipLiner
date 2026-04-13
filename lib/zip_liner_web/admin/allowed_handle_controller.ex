defmodule ZipLinerWeb.Admin.AllowedHandleController do
  use ZipLinerWeb, :controller

  plug ZipLinerWeb.Plugs.RequireAdmin

  alias ZipLiner.Accounts
  alias ZipLiner.Accounts.AllowedGithubHandle

  def index(conn, _params) do
    handles = Accounts.list_allowed_handles()
    changeset = Accounts.change_allowed_handle(%AllowedGithubHandle{})
    render(conn, :index, handles: handles, changeset: changeset)
  end

  def create(conn, %{"allowed_github_handle" => handle_params}) do
    case Accounts.create_allowed_handle(handle_params) do
      {:ok, _handle} ->
        conn
        |> put_flash(:info, "GitHub handle added to whitelist.")
        |> redirect(to: ~p"/admin/allowed_handles")

      {:error, changeset} ->
        handles = Accounts.list_allowed_handles()
        render(conn, :index, handles: handles, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    handle = Accounts.get_allowed_handle!(id)
    {:ok, _} = Accounts.delete_allowed_handle(handle)

    conn
    |> put_flash(:info, "GitHub handle removed from whitelist.")
    |> redirect(to: ~p"/admin/allowed_handles")
  end
end
