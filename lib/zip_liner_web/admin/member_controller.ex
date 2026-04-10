defmodule ZipLinerWeb.Admin.MemberController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Accounts

  def index(conn, _params) do
    members = Accounts.list_members()
    render(conn, :index, members: members)
  end

  def show(conn, %{"id" => id}) do
    member = Accounts.get_member!(id)
    render(conn, :show, member: member)
  end

  def edit(conn, %{"id" => id}) do
    member = Accounts.get_member!(id)
    cohorts = Accounts.list_cohorts()
    changeset = Accounts.change_member(member)
    render(conn, :edit, member: member, cohorts: cohorts, changeset: changeset)
  end

  def update(conn, %{"id" => id, "member" => member_params}) do
    member = Accounts.get_member!(id)

    case Accounts.update_member(member, member_params) do
      {:ok, updated_member} ->
        conn
        |> put_flash(:info, "Member updated.")
        |> redirect(to: ~p"/admin/members/#{updated_member.id}")

      {:error, changeset} ->
        cohorts = Accounts.list_cohorts()
        render(conn, :edit, member: member, cohorts: cohorts, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    member = Accounts.get_member!(id)
    {:ok, _} = Accounts.deprovision_member(member)

    conn
    |> put_flash(:info, "Member deprovisioned.")
    |> redirect(to: ~p"/admin/members")
  end
end
