defmodule ZipLinerWeb.FeedController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Social

  def index(conn, _params) do
    member_id = conn.assigns.current_member.id
    posts = Social.list_feed_posts(member_id)
    post_ids = Enum.map(posts, & &1.id)

    reaction_counts = Social.get_reaction_counts_batch(post_ids)
    my_reactions = Social.member_reaction_kinds_batch(post_ids, member_id)

    changeset = Social.change_post(%ZipLiner.Social.Post{})

    render(conn, :index,
      posts: posts,
      changeset: changeset,
      reaction_counts: reaction_counts,
      my_reactions: my_reactions
    )
  end
end
