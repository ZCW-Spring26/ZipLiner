defmodule ZipLiner.Accounts.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @roles ~w(student alumni instructor staff mentor guest)a
  @statuses ~w(active suspended deprovisioned)a
  @admin_handles ~w(kristofer)

  schema "members" do
    field :github_id, :string
    field :github_username, :string
    field :github_avatar_url, :string
    field :linkedin_id, :string
    field :linkedin_url, :string
    field :display_name, :string
    field :bio, :string
    field :current_title, :string
    field :employer, :string
    field :location, :string
    field :role, Ecto.Enum, values: @roles, default: :student
    field :status, Ecto.Enum, values: @statuses, default: :active
    field :is_admin, :boolean, default: false
    field :open_to_opportunities, :boolean, default: false
    field :skills, {:array, :string}, default: []
    field :avatar_source, Ecto.Enum, values: [:github, :linkedin], default: :github

    belongs_to :cohort, ZipLiner.Accounts.Cohort

    has_many :posts, ZipLiner.Social.Post, foreign_key: :author_id
    has_many :projects, ZipLiner.Projects.Project, foreign_key: :owner_id

    has_many :connections_as_a,
             ZipLiner.Social.Connection,
             foreign_key: :member_id_a

    has_many :connections_as_b,
             ZipLiner.Social.Connection,
             foreign_key: :member_id_b

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [
      :github_id,
      :github_username,
      :github_avatar_url,
      :linkedin_id,
      :linkedin_url,
      :display_name,
      :bio,
      :current_title,
      :employer,
      :location,
      :role,
      :status,
      :open_to_opportunities,
      :skills,
      :avatar_source,
      :cohort_id
    ])
    |> validate_required([:github_id, :github_username, :display_name])
    |> unique_constraint(:github_id)
    |> unique_constraint(:github_username)
    |> validate_length(:display_name, max: 100)
    |> validate_length(:bio, max: 280)
  end

  def github_oauth_changeset(member, attrs) do
    member
    |> cast(attrs, [:github_id, :github_username, :github_avatar_url, :display_name])
    |> validate_required([:github_id, :github_username])
    |> unique_constraint(:github_id)
    |> unique_constraint(:github_username)
    |> maybe_set_admin()
  end

  # Automatically grant admin privileges to handles listed in @admin_handles.
  defp maybe_set_admin(changeset) do
    username = get_field(changeset, :github_username)

    if username && String.downcase(username) in @admin_handles do
      put_change(changeset, :is_admin, true)
    else
      changeset
    end
  end
end
