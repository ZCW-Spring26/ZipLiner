defmodule ZipLiner.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(connection_request connection_accepted mention reply reaction
            introduction_request staff_announcement cohort_post)a

  schema "notifications" do
    field :type, Ecto.Enum, values: @types
    field :payload, :map, default: %{}
    field :read_at, :utc_datetime

    belongs_to :recipient, ZipLiner.Accounts.Member, foreign_key: :recipient_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:type, :payload, :read_at, :recipient_id])
    |> validate_required([:type, :recipient_id])
  end
end
