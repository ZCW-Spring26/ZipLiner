defmodule ZipLiner.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring access to the application's
  data layer. You may define functions here to be used as helpers in your tests.

  Finally, if the test case interacts with the database, we enable the SQL
  sandbox, so changes done to the database are reverted at the end of every
  test. This project uses SQLite3 via `ecto_sqlite3`. Note that SQLite3's
  file-level locking means async database tests should be used with caution
  and are generally not recommended.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias ZipLiner.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import ZipLiner.DataCase
    end
  end

  setup tags do
    ZipLiner.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(ZipLiner.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.
  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
