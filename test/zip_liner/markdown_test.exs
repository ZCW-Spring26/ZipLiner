defmodule ZipLiner.MarkdownTest do
  use ExUnit.Case, async: true

  alias ZipLiner.Markdown

  describe "to_html/1" do
    test "converts plain text to a paragraph" do
      result = Markdown.to_html("Hello world")
      assert {:safe, html} = result
      assert html =~ "<p"
      assert html =~ "Hello world"
    end

    test "renders URLs as clickable links" do
      result = Markdown.to_html("Visit https://example.com for details")
      assert {:safe, html} = result
      assert html =~ ~s(<a href="https://example.com")
    end

    test "renders markdown link syntax" do
      result = Markdown.to_html("[ZipCode](https://zipcodewilmington.com)")
      assert {:safe, html} = result
      assert html =~ ~s(<a href="https://zipcodewilmington.com")
      assert html =~ "ZipCode"
    end

    test "renders bold text" do
      result = Markdown.to_html("**bold text**")
      assert {:safe, html} = result
      assert html =~ "<strong>"
    end

    test "renders italic text" do
      result = Markdown.to_html("_italic text_")
      assert {:safe, html} = result
      assert html =~ "<em>"
    end

    test "renders unordered lists" do
      result = Markdown.to_html("- item one\n- item two")
      assert {:safe, html} = result
      assert html =~ "<ul>"
      assert html =~ "<li>"
    end

    test "renders code spans" do
      result = Markdown.to_html("`some_code`")
      assert {:safe, html} = result
      assert html =~ "<code>"
    end

    test "strips dangerous script tags" do
      result = Markdown.to_html("<script>alert('xss')</script>")
      assert {:safe, html} = result
      refute html =~ "<script>"
      refute html =~ "alert"
    end

    test "handles empty string" do
      result = Markdown.to_html("")
      assert {:safe, _html} = result
    end

    test "returns a Phoenix.HTML.safe tuple" do
      assert {:safe, _} = Markdown.to_html("hello")
    end
  end
end
