defmodule ZipLiner.AccountsFixtures do
  @moduledoc """
  Test fixtures for the Accounts context.
  """

  alias ZipLiner.Accounts
  alias ZipLiner.Repo

  def cohort_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "Test Cohort #{System.unique_integer([:positive])}",
      start_date: ~D[2024-01-01],
      graduation_date: ~D[2024-04-01]
    })
  end

  def cohort_fixture(attrs \\ %{}) do
    {:ok, cohort} =
      attrs
      |> cohort_attrs()
      |> Accounts.create_cohort()

    cohort
  end

  def member_attrs(attrs \\ %{}) do
    n = System.unique_integer([:positive])

    Enum.into(attrs, %{
      github_id: "github_#{n}",
      github_username: "user_#{n}",
      github_avatar_url: "https://avatars.githubusercontent.com/u/#{n}",
      display_name: "Test User #{n}"
    })
  end

  def member_fixture(attrs \\ %{}) do
    {is_admin, attrs} = Map.pop(attrs, :is_admin, false)

    {:ok, member} =
      attrs
      |> member_attrs()
      |> Accounts.create_member()

    if is_admin do
      {:ok, member} =
        member
        |> Ecto.Changeset.change(%{is_admin: true})
        |> Repo.update()

      member
    else
      member
    end
  end
end
