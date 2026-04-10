defmodule ZipLinerWeb.MemberController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Accounts
  alias ZipLiner.Social

  def index(conn, params) do
    members =
      case params do
        %{"cohort_id" => cohort_id} -> Accounts.list_members_by_cohort(cohort_id)
        _ -> Accounts.list_members()
      end

    cohorts = Accounts.list_cohorts()
    render(conn, :index, members: members, cohorts: cohorts)
  end

  def show(conn, %{"id" => id}) do
    member = Accounts.get_member!(id)
    current_member = conn.assigns.current_member
    is_connected = Social.connected?(current_member.id, member.id)
    pending = Social.get_pending_connection(current_member.id, member.id)
    render(conn, :show, member: member, is_connected: is_connected, pending_connection: pending)
  end

  def edit(conn, %{"id" => id}) do
    member = Accounts.get_member!(id)

    if member.id != conn.assigns.current_member.id do
      conn
      |> put_flash(:error, "You can only edit your own profile.")
      |> redirect(to: ~p"/members/#{member.id}")
    else
      changeset = Accounts.change_member(member)
      render(conn, :edit, member: member, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "member" => member_params}) do
    member = Accounts.get_member!(id)

    if member.id != conn.assigns.current_member.id do
      conn
      |> put_flash(:error, "You can only edit your own profile.")
      |> redirect(to: ~p"/members/#{member.id}")
    else
      case Accounts.update_member(member, member_params) do
        {:ok, updated_member} ->
          conn
          |> put_flash(:info, "Profile updated.")
          |> redirect(to: ~p"/members/#{updated_member.id}")

        {:error, changeset} ->
          render(conn, :edit, member: member, changeset: changeset)
      end
    end
  end

  def connect(conn, %{"id" => id}) do
    target_member = Accounts.get_member!(id)
    current_member = conn.assigns.current_member

    case Social.send_connection_request(current_member.id, target_member.id) do
      {:ok, _connection} ->
        conn
        |> put_flash(:info, "Connection request sent to #{target_member.display_name}.")
        |> redirect(to: ~p"/members/#{target_member.id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not send connection request.")
        |> redirect(to: ~p"/members/#{target_member.id}")
    end
  end

  def accept_connection(conn, %{"id" => id}) do
    target_member = Accounts.get_member!(id)
    current_member = conn.assigns.current_member

    case Social.get_pending_connection(target_member.id, current_member.id) do
      nil ->
        conn
        |> put_flash(:error, "No pending connection request found.")
        |> redirect(to: ~p"/members/#{target_member.id}")

      connection ->
        Social.accept_connection(connection)

        conn
        |> put_flash(:info, "You are now connected with #{target_member.display_name}!")
        |> redirect(to: ~p"/members/#{target_member.id}")
    end
  end
end
