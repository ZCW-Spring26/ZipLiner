defmodule ZipLinerWeb.ChannelController do
  use ZipLinerWeb, :controller

  import Ecto.Query, warn: false
  alias ZipLiner.Social
  alias ZipLiner.Repo

  def index(conn, _params) do
    channels = Social.list_channels()
    render(conn, :index, channels: channels)
  end

  def show(conn, %{"id" => id}) do
    channel = Social.get_channel!(id)

    posts =
      ZipLiner.Social.Post
      |> where([p], p.channel_id == ^channel.id)
      |> order_by([p], desc: p.inserted_at)
      |> preload(:author)
      |> Repo.all()

    render(conn, :show, channel: channel, posts: posts)
  end
end
