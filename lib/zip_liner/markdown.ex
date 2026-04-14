defmodule ZipLiner.Markdown do
  @moduledoc """
  Renders Markdown text as sanitized HTML safe for use in HEEx templates.
  """

  @doc """
  Converts a Markdown string to a Phoenix-safe HTML string.

  The output is sanitized to allow only the tags produced by a Markdown
  processor, preventing XSS from raw `<script>` or similar tags.
  """
  @spec to_html(String.t()) :: Phoenix.HTML.safe()
  def to_html(text) when is_binary(text) do
    html =
      case Earmark.as_html(text, compact_output: true) do
        {:ok, html, _deprecations} -> html
        {:error, html, _messages} -> html
      end

    html
    |> HtmlSanitizeEx.markdown_html()
    |> Phoenix.HTML.raw()
  end
end
