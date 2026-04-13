defmodule ZipLinerWeb.Plugs.RequireAdmin do
  @moduledoc """
  Redirects non-admin users away from admin-only pages.

  Must be used after `RequireAuth` so that `conn.assigns.current_member` is
  already populated.
  """

  import Plug.Conn
  import Phoenix.Controller
  use ZipLinerWeb, :verified_routes

  def init(opts), do: opts

  def call(conn, _opts) do
    member = conn.assigns[:current_member]

    if member && member.is_admin do
      conn
    else
      conn
      |> put_flash(:error, "You must be an administrator to access that page.")
      |> redirect(to: ~p"/feed")
      |> halt()
    end
  end
end
