defmodule ZipLiner.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(in_progress completed archived looking_for_collaborators)a

  schema "projects" do
    field :name, :string
    field :tagline, :string
    field :description, :string
    field :status, Ecto.Enum, values: @statuses, default: :in_progress
    field :repo_url, :string
    field :demo_url, :string
    field :tech_stack, {:array, :string}, default: []
    field :role, :string
    field :cohort_project, :boolean, default: false

    belongs_to :owner, ZipLiner.Accounts.Member, foreign_key: :owner_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :name,
      :tagline,
      :description,
      :status,
      :repo_url,
      :demo_url,
      :tech_stack,
      :role,
      :cohort_project,
      :owner_id
    ])
    |> validate_required([:name, :owner_id])
    |> validate_length(:name, max: 80)
    |> validate_length(:tagline, max: 120)
    |> validate_length(:description, max: 800)
    |> validate_url(:repo_url)
    |> validate_url(:demo_url)
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: scheme} when scheme in ["http", "https"] -> []
        _ -> [{field, "must be a valid http or https URL"}]
      end
    end)
  end
end
