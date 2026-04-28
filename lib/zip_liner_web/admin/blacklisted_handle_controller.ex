defmodule ZipLinerWeb.Admin.BlacklistedHandleController do
  use ZipLinerWeb, :controller

  plug ZipLinerWeb.Plugs.RequireAdmin

  alias ZipLiner.Accounts
  alias ZipLiner.Accounts.BlacklistedGithubHandle

  def index(conn, _params) do
    handles = Accounts.list_blacklisted_handles()
    changeset = Accounts.change_blacklisted_handle(%BlacklistedGithubHandle{})
    render(conn, :index, handles: handles, changeset: changeset)
  end

  def create(conn, %{"blacklisted_github_handle" => handle_params}) do
    case Accounts.create_blacklisted_handle(handle_params) do
      {:ok, _handle} ->
        conn
        |> put_flash(:info, "GitHub handle added to blacklist.")
        |> redirect(to: ~p"/admin/blacklisted_handles")

      {:error, changeset} ->
        handles = Accounts.list_blacklisted_handles()
        render(conn, :index, handles: handles, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    handle = Accounts.get_blacklisted_handle!(id)
    {:ok, _} = Accounts.delete_blacklisted_handle(handle)

    conn
    |> put_flash(:info, "GitHub handle removed from blacklist.")
    |> redirect(to: ~p"/admin/blacklisted_handles")
  end
end
