defmodule ZipLiner.Accounts.Cohort do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cohorts" do
    field :name, :string
    field :start_date, :date
    field :graduation_date, :date

    has_many :members, ZipLiner.Accounts.Member

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cohort, attrs) do
    cohort
    |> cast(attrs, [:name, :start_date, :graduation_date])
    |> validate_required([:name, :start_date])
    |> validate_length(:name, max: 100)
  end
end
