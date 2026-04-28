defmodule ZipLinerWeb.ChannelController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Blog
  alias ZipLiner.Accounts

  def index(conn, _params) do
    blog_members = Blog.list_blog_members()
    render(conn, :index, blog_members: blog_members)
  end

  def show(conn, %{"id" => member_id}) do
    member = Accounts.get_member!(member_id)
    current_member = conn.assigns.current_member

    articles =
      if current_member.id == member.id do
        Blog.list_articles_by_author(member.id)
      else
        Blog.list_public_and_pinned_articles_by_author(member.id)
      end

    render(conn, :show, member: member, articles: articles)
  end
end
