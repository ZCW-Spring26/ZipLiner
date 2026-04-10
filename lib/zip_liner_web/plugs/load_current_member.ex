defmodule ZipLinerWeb.Plugs.LoadCurrentMember do
  @moduledoc """
  Loads the current authenticated member from the session into the connection assigns.
  """

  import Plug.Conn
  alias ZipLiner.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :current_member_id) do
      nil ->
        assign(conn, :current_member, nil)

      member_id ->
        try do
          assign(conn, :current_member, Accounts.get_member!(member_id))
        rescue
          Ecto.NoResultsError ->
            conn
            |> delete_session(:current_member_id)
            |> assign(:current_member, nil)
        end
    end
  end
end
