defmodule ZipLinerWeb.SettingsController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Accounts

  def edit(conn, _params) do
    member = conn.assigns.current_member
    changeset = Accounts.change_member(member)
    render(conn, :edit, member: member, changeset: changeset)
  end

  def update(conn, %{"member" => member_params}) do
    member = conn.assigns.current_member

    case Accounts.update_member(member, member_params) do
      {:ok, _updated_member} ->
        conn
        |> put_flash(:info, "Settings saved.")
        |> redirect(to: ~p"/settings")

      {:error, changeset} ->
        render(conn, :edit, member: member, changeset: changeset)
    end
  end
end
