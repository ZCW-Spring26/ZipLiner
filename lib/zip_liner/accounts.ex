defmodule ZipLiner.Accounts do
  @moduledoc """
  The Accounts context manages Members and Cohorts.
  """

  import Ecto.Query, warn: false
  alias ZipLiner.Repo
  alias ZipLiner.Accounts.{Member, Cohort, AllowedGithubHandle}

  # ---------------------------------------------------------------------------
  # Members
  # ---------------------------------------------------------------------------

  @doc "Returns the list of all members."
  def list_members do
    Repo.all(Member)
  end

  @doc "Returns members filtered by cohort."
  def list_members_by_cohort(cohort_id) do
    Member
    |> where([m], m.cohort_id == ^cohort_id and m.status == :active)
    |> Repo.all()
  end

  @doc "Gets a single member by id. Raises if not found."
  def get_member!(id), do: Repo.get!(Member, id)

  @doc "Gets a member by github_id, returns nil if not found."
  def get_member_by_github_id(github_id) do
    Repo.get_by(Member, github_id: github_id)
  end

  @doc """
  Finds or creates a member from GitHub OAuth data.

  Returns `{:error, :not_whitelisted}` when the whitelist is non-empty and the
  GitHub username is not on it.  Otherwise upserts the member record and
  returns `{:ok, member}` or `{:error, changeset}`.
  """
  def find_or_create_from_github(%{
        "id" => github_id,
        "login" => username,
        "name" => name,
        "avatar_url" => avatar_url
      }) do
    if handle_allowed?(username) do
      github_id_str = to_string(github_id)
      display_name = name || username

      case get_member_by_github_id(github_id_str) do
        nil ->
          %Member{}
          |> Member.github_oauth_changeset(%{
            github_id: github_id_str,
            github_username: username,
            github_avatar_url: avatar_url,
            display_name: display_name
          })
          |> Repo.insert()

        member ->
          member
          |> Member.github_oauth_changeset(%{
            github_username: username,
            github_avatar_url: avatar_url,
            display_name: display_name
          })
          |> Repo.update()
      end
    else
      {:error, :not_whitelisted}
    end
  end

  @doc "Creates a member."
  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a member."
  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a member (soft-delete by setting status to :deprovisioned)."
  def deprovision_member(%Member{} = member) do
    update_member(member, %{status: :deprovisioned})
  end

  @doc "Returns an `%Ecto.Changeset{}` for tracking member changes."
  def change_member(%Member{} = member, attrs \\ %{}) do
    Member.changeset(member, attrs)
  end

  # ---------------------------------------------------------------------------
  # Cohorts
  # ---------------------------------------------------------------------------

  @doc "Returns the list of cohorts."
  def list_cohorts do
    Repo.all(Cohort)
  end

  @doc "Gets a single cohort. Raises if not found."
  def get_cohort!(id), do: Repo.get!(Cohort, id)

  @doc "Creates a cohort."
  def create_cohort(attrs \\ %{}) do
    %Cohort{}
    |> Cohort.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a cohort."
  def update_cohort(%Cohort{} = cohort, attrs) do
    cohort
    |> Cohort.changeset(attrs)
    |> Repo.update()
  end

  @doc "Returns an `%Ecto.Changeset{}` for tracking cohort changes."
  def change_cohort(%Cohort{} = cohort, attrs \\ %{}) do
    Cohort.changeset(cohort, attrs)
  end

  # ---------------------------------------------------------------------------
  # Allowed GitHub Handles (whitelist)
  # ---------------------------------------------------------------------------

  @doc "Returns all allowed GitHub handles."
  def list_allowed_handles do
    AllowedGithubHandle
    |> order_by([h], asc: h.handle)
    |> Repo.all()
  end

  @doc "Gets a single allowed handle by id. Raises if not found."
  def get_allowed_handle!(id), do: Repo.get!(AllowedGithubHandle, id)

  @doc "Creates an allowed GitHub handle."
  def create_allowed_handle(attrs \\ %{}) do
    %AllowedGithubHandle{}
    |> AllowedGithubHandle.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Deletes an allowed GitHub handle."
  def delete_allowed_handle(%AllowedGithubHandle{} = handle) do
    Repo.delete(handle)
  end

  @doc "Returns an `%Ecto.Changeset{}` for tracking allowed handle changes."
  def change_allowed_handle(%AllowedGithubHandle{} = handle, attrs \\ %{}) do
    AllowedGithubHandle.changeset(handle, attrs)
  end

  @doc """
  Returns `true` when:
  - the whitelist is empty (no restrictions in place), or
  - `username` appears in the whitelist (case-insensitive).
  """
  def handle_allowed?(username) do
    count = Repo.aggregate(AllowedGithubHandle, :count)

    if count == 0 do
      true
    else
      normalized = String.downcase(username)

      AllowedGithubHandle
      |> where([h], fragment("lower(?)", h.handle) == ^normalized)
      |> Repo.exists?()
    end
  end
end
