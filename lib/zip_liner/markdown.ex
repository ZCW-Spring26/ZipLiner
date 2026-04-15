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

  @doc """
  Converts a plain-text string to a Phoenix-safe HTML string where any
  bare http/https URLs are wrapped in clickable `<a>` tags. All other
  content is HTML-escaped to prevent XSS.

  Returns an empty safe string when given `nil`.
  """

  # Matches http/https URLs; stops before whitespace or HTML-special characters.
  # Trailing sentence punctuation (.,;:!?) is stripped from the match so that
  # e.g. "Visit https://example.com." does not include the period in the href.
  @url_regex ~r{https?://[^\s<>"']+}

  @spec autolink(String.t() | nil) :: Phoenix.HTML.safe()
  def autolink(nil), do: Phoenix.HTML.raw("")

  def autolink(text) when is_binary(text) do
    html =
      @url_regex
      |> Regex.split(text, include_captures: true)
      |> Enum.map_join("", fn part ->
        if Regex.match?(@url_regex, part) do
          {url, suffix} = split_trailing_punctuation(part)

          safe_url =
            url
            |> Phoenix.HTML.html_escape()
            |> Phoenix.HTML.safe_to_string()

          safe_suffix =
            suffix
            |> Phoenix.HTML.html_escape()
            |> Phoenix.HTML.safe_to_string()

          ~s(<a href="#{safe_url}" target="_blank" rel="noopener noreferrer">#{safe_url}</a>#{safe_suffix})
        else
          part
          |> Phoenix.HTML.html_escape()
          |> Phoenix.HTML.safe_to_string()
        end
      end)

    Phoenix.HTML.raw(html)
  end

  # Splits common sentence-ending punctuation from the tail of a matched URL so
  # that "See https://example.com." does not include the period in the href.
  # Only strips characters that cannot legitimately end a URL path segment.
  defp split_trailing_punctuation(url) do
    case Regex.run(~r/^(.*?)([\.,;:!?]+)$/, url) do
      [_, base, trailing] -> {base, trailing}
      nil -> {url, ""}
    end
  end
end
