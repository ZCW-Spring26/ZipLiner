defmodule ZipLinerWeb.AboutController do
  use ZipLinerWeb, :controller

  def show(conn, _params) do
    render(conn, :show)
  end
end
