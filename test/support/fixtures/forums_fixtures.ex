defmodule ZipLiner.ForumsFixtures do
  @moduledoc """
  Test fixtures for the Forums context.
  """

  alias ZipLiner.Forums

  def thread_fixture(author_id, attrs \\ %{}) do
    {:ok, thread} =
      attrs
      |> Enum.into(%{
        title: "Test Thread #{System.unique_integer([:positive])}",
        body: "This is the body of the test thread.",
        author_id: author_id
      })
      |> Forums.create_thread()

    thread
  end

  def comment_fixture(thread_id, author_id, attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "This is a test comment.",
        thread_id: thread_id,
        author_id: author_id
      })
      |> Forums.create_comment()

    comment
  end
end
