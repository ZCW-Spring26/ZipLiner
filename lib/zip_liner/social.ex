defmodule ZipLiner.Social do
  @moduledoc """
  The Social context manages Connections, Posts, Channels, Reactions,
  Replies and Direct Messages.
  """

  import Ecto.Query, warn: false
  alias ZipLiner.Repo
  alias ZipLiner.Social.{Channel, Connection, DirectMessage, Post, Reaction, Reply}

  # ---------------------------------------------------------------------------
  # Connections
  # ---------------------------------------------------------------------------

  @doc "Lists all accepted connections for a member."
  def list_connections(member_id) do
    Connection
    |> where(
      [c],
      (c.member_id_a == ^member_id or c.member_id_b == ^member_id) and c.status == :accepted
    )
    |> Repo.all()
  end

  @doc "Returns true if two members are directly connected (1st degree)."
  def connected?(member_id_a, member_id_b) do
    Connection
    |> where(
      [c],
      c.status == :accepted and
        ((c.member_id_a == ^member_id_a and c.member_id_b == ^member_id_b) or
           (c.member_id_a == ^member_id_b and c.member_id_b == ^member_id_a))
    )
    |> Repo.exists?()
  end

  @doc "Sends a connection request from member_id_a to member_id_b."
  def send_connection_request(member_id_a, member_id_b) do
    %Connection{}
    |> Connection.changeset(%{member_id_a: member_id_a, member_id_b: member_id_b})
    |> Repo.insert()
  end

  @doc "Accepts a pending connection request."
  def accept_connection(%Connection{} = connection) do
    connection
    |> Connection.changeset(%{status: :accepted})
    |> Repo.update()
  end

  @doc "Returns a pending connection request between two members, if any."
  def get_pending_connection(member_id_a, member_id_b) do
    Connection
    |> where(
      [c],
      c.status == :pending and
        ((c.member_id_a == ^member_id_a and c.member_id_b == ^member_id_b) or
           (c.member_id_a == ^member_id_b and c.member_id_b == ^member_id_a))
    )
    |> Repo.one()
  end

  # ---------------------------------------------------------------------------
  # Channels
  # ---------------------------------------------------------------------------

  @doc "Returns all channels visible to the given member."
  def list_channels do
    Repo.all(Channel)
  end

  @doc "Gets a single channel. Raises if not found."
  def get_channel!(id), do: Repo.get!(Channel, id)

  @doc "Creates a channel."
  def create_channel(attrs \\ %{}) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Repo.insert()
  end

  # ---------------------------------------------------------------------------
  # Posts
  # ---------------------------------------------------------------------------

  @doc "Returns the feed posts for a member (from connections + channels)."
  def list_feed_posts(member_id, limit \\ 50) do
    connection_member_ids =
      Connection
      |> where(
        [c],
        (c.member_id_a == ^member_id or c.member_id_b == ^member_id) and c.status == :accepted
      )
      |> select([c], fragment("CASE WHEN ? = ? THEN ? ELSE ? END", c.member_id_a, ^member_id, c.member_id_b, c.member_id_a))
      |> Repo.all()

    all_ids = [member_id | connection_member_ids]

    Post
    |> where([p], p.author_id in ^all_ids)
    |> order_by([p], desc: p.inserted_at)
    |> limit(^limit)
    |> preload(:author)
    |> Repo.all()
  end

  @doc "Gets a single post. Raises if not found."
  def get_post!(id), do: Repo.get!(Post, id)

  @doc "Creates a post."
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Returns a changeset for a post."
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  # ---------------------------------------------------------------------------
  # Reactions
  # ---------------------------------------------------------------------------

  @doc "Adds a reaction to a post."
  def add_reaction(post_id, member_id, kind) do
    %Reaction{}
    |> Reaction.changeset(%{post_id: post_id, member_id: member_id, kind: kind})
    |> Repo.insert()
  end

  @doc "Removes a reaction from a post."
  def remove_reaction(post_id, member_id, kind) do
    Reaction
    |> where([r], r.post_id == ^post_id and r.member_id == ^member_id and r.kind == ^kind)
    |> Repo.delete_all()
  end

  # ---------------------------------------------------------------------------
  # Replies
  # ---------------------------------------------------------------------------

  @doc "Creates a reply on a post."
  def create_reply(attrs \\ %{}) do
    %Reply{}
    |> Reply.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Lists replies for a post."
  def list_replies(post_id) do
    Reply
    |> where([r], r.post_id == ^post_id)
    |> order_by([r], asc: r.inserted_at)
    |> preload(:author)
    |> Repo.all()
  end

  # ---------------------------------------------------------------------------
  # Direct Messages
  # ---------------------------------------------------------------------------

  @doc "Sends a direct message."
  def send_direct_message(attrs \\ %{}) do
    %DirectMessage{}
    |> DirectMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Lists direct messages between two members."
  def list_direct_messages(member_id_a, member_id_b) do
    DirectMessage
    |> where(
      [dm],
      (dm.sender_id == ^member_id_a and dm.recipient_id == ^member_id_b) or
        (dm.sender_id == ^member_id_b and dm.recipient_id == ^member_id_a)
    )
    |> order_by([dm], asc: dm.inserted_at)
    |> Repo.all()
  end
end
