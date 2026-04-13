defmodule ZipLinerWeb.AuthController do
  @moduledoc """
  Handles GitHub OAuth2 authentication via Ueberauth.
  """

  use ZipLinerWeb, :controller

  plug Ueberauth

  alias ZipLiner.Accounts

  @doc """
  Ueberauth redirect phase — redirects the user to GitHub.
  This is handled automatically by the Ueberauth plug.
  """
  def request(conn, _params) do
    conn
  end

  @doc """
  Ueberauth callback phase — processes the GitHub response.
  """
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate with GitHub. Please try again.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    github_data = %{
      "id" => auth.uid,
      "login" => auth.info.nickname,
      "name" => auth.info.name,
      "avatar_url" => auth.info.image
    }

    case Accounts.find_or_create_from_github(github_data) do
      {:ok, member} ->
        conn
        |> put_session(:current_member_id, member.id)
        |> put_flash(:info, "Welcome back, #{member.display_name}!")
        |> redirect(to: ~p"/feed")

      {:error, :not_whitelisted} ->
        conn
        |> put_flash(
          :error,
          "Your GitHub account is not authorised to access this site. " <>
            "Please contact an administrator."
        )
        |> redirect(to: ~p"/")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not sign you in. Please contact an administrator.")
        |> redirect(to: ~p"/")
    end
  end

  @doc "Logs out the current member."
  def logout(conn, _params) do
    conn
    |> delete_session(:current_member_id)
    |> put_flash(:info, "You have been signed out.")
    |> redirect(to: ~p"/")
  end
end
