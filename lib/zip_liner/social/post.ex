defmodule ZipLiner.Social.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(status article project_showcase long_form cohort_shoutout job_signal)a

  @max_lengths %{
    status: 300,
    article: 500,
    project_showcase: 800,
    long_form: 10_000,
    cohort_shoutout: 300,
    job_signal: 500
  }

  schema "posts" do
    field :type, Ecto.Enum, values: @types, default: :status
    field :content, :string
    field :url, :string
    field :url_title, :string

    belongs_to :author, ZipLiner.Accounts.Member, foreign_key: :author_id
    belongs_to :channel, ZipLiner.Social.Channel

    has_many :reactions, ZipLiner.Social.Reaction
    has_many :replies, ZipLiner.Social.Reply

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:type, :content, :url, :url_title, :author_id, :channel_id])
    |> validate_required([:type, :content, :author_id])
    |> validate_content_length()
  end

  defp validate_content_length(changeset) do
    type = get_field(changeset, :type)
    max = Map.get(@max_lengths, type, 500)
    validate_length(changeset, :content, max: max)
  end
end
