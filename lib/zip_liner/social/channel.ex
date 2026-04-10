defmodule ZipLiner.Social.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(cohort topic staff dm)a

  schema "channels" do
    field :name, :string
    field :type, Ecto.Enum, values: @types
    field :description, :string

    belongs_to :cohort, ZipLiner.Accounts.Cohort

    has_many :posts, ZipLiner.Social.Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :type, :description, :cohort_id])
    |> validate_required([:name, :type])
    |> validate_length(:name, max: 100)
    |> validate_length(:description, max: 500)
    |> unique_constraint(:name)
  end
end
