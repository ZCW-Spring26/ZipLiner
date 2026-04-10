defmodule ZipLinerWeb.PageController do
  use ZipLinerWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_member] do
      redirect(conn, to: ~p"/feed")
    else
      render(conn, :home)
    end
  end
end
