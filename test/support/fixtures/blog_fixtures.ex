defmodule ZipLiner.BlogFixtures do
  @moduledoc """
  Test fixtures for the Blog context.
  """

  alias ZipLiner.Blog

  def article_fixture(author_id, attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        title: "Test Article #{System.unique_integer([:positive])}",
        body: "This is the body of the test article.",
        visibility: "private",
        author_id: author_id
      })
      |> Blog.create_article()

    article
  end

  def comment_fixture(article_id, author_id, attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "This is a test article comment.",
        article_id: article_id,
        author_id: author_id
      })
      |> Blog.create_comment()

    comment
  end
end
