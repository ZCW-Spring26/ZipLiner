defmodule ZipLinerWeb.Plugs.RequireAuth do
  @moduledoc """
  Redirects unauthenticated users to the home page.
  """

  import Plug.Conn
  import Phoenix.Controller
  use ZipLinerWeb, :verified_routes

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_member] do
      conn
    else
      conn
      |> put_flash(:error, "You must be signed in to access that page.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
