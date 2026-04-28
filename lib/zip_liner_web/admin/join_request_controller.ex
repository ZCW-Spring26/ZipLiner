defmodule ZipLinerWeb.Admin.JoinRequestController do
  use ZipLinerWeb, :controller

  plug ZipLinerWeb.Plugs.RequireAdmin

  alias ZipLiner.Accounts

  def index(conn, _params) do
    pending = Accounts.list_pending_join_requests()
    all = Accounts.list_join_requests()
    render(conn, :index, pending: pending, all: all)
  end

  def approve(conn, %{"id" => id}) do
    request = Accounts.get_join_request!(id)

    case Accounts.approve_join_request(request) do
      {:ok, _member} ->
        conn
        |> put_flash(:info, "@#{request.github_username} has been approved and can now sign in.")
        |> redirect(to: ~p"/admin/join_requests")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not approve request. The member may already exist.")
        |> redirect(to: ~p"/admin/join_requests")
    end
  end

  def deny(conn, %{"id" => id, "blacklist" => blacklist}) do
    request = Accounts.get_join_request!(id)
    blacklist? = blacklist == "true"

    case Accounts.deny_join_request(request, blacklist?) do
      {:ok, _} ->
        message =
          if blacklist? do
            "@#{request.github_username} has been denied and added to the blacklist."
          else
            "@#{request.github_username} has been denied."
          end

        conn
        |> put_flash(:info, message)
        |> redirect(to: ~p"/admin/join_requests")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not deny request.")
        |> redirect(to: ~p"/admin/join_requests")
    end
  end

  def deny(conn, %{"id" => id}) do
    deny(conn, %{"id" => id, "blacklist" => "false"})
  end
end
