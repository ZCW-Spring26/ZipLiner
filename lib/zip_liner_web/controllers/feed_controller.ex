defmodule ZipLinerWeb.FeedController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Social

  def index(conn, _params) do
    posts = Social.list_feed_posts(conn.assigns.current_member.id)
    changeset = Social.change_post(%ZipLiner.Social.Post{})
    render(conn, :index, posts: posts, changeset: changeset)
  end
end
