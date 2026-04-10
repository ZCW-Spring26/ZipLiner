defmodule ZipLinerWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by tests that require
  setting up a connection. Such tests rely on `Phoenix.ConnTest` and
  also import other functionality to make it easier to build common
  data structures and query the data layer.

  Finally, if the test case interacts with the database, we enable the
  SQL sandbox, so changes done to the database are reverted at the end
  of every test. This project uses SQLite3 via `ecto_sqlite3`. Note that
  SQLite3's file-level locking means async database tests should be used
  with caution and are generally not recommended.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      import ZipLinerWeb.ConnCase

      @endpoint ZipLinerWeb.Endpoint
    end
  end

  setup tags do
    ZipLiner.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that logs a member in.

      setup :log_in_member

  It stores an updated connection and a registered member in the test context.
  """
  def log_in_member(%{conn: conn}) do
    member = ZipLiner.AccountsFixtures.member_fixture()
    %{conn: log_in_member(conn, member), member: member}
  end

  @doc """
  Logs the given `member` into the `conn`.
  """
  def log_in_member(conn, member) do
    Plug.Conn.put_session(conn, :current_member_id, member.id)
  end
end
