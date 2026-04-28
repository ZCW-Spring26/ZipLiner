defmodule ZipLiner.Accounts do
  @moduledoc """
  The Accounts context manages Members and Cohorts.
  """

  import Ecto.Query, warn: false
  alias ZipLiner.Repo
  alias ZipLiner.Accounts.{Member, Cohort, AllowedGithubHandle, BlacklistedGithubHandle, JoinRequest}

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

  @doc "Gets a member by github_username, returns nil if not found."
  def get_member_by_github_username(username) do
    Repo.get_by(Member, github_username: username)
  end

  @doc """
  Finds or creates a member from GitHub OAuth data.

  Returns:
  - `{:error, :blacklisted}` if the handle is on the blacklist.
  - `{:error, :join_requested}` if the handle is not on the whitelist and a join
    request has been created/updated.
  - `{:ok, member}` if the handle is whitelisted or the whitelist is empty.
  - `{:error, changeset}` on a database error.
  """
  def find_or_create_from_github(%{
        "id" => github_id,
        "login" => username,
        "name" => name,
        "avatar_url" => avatar_url
      }) do
    cond do
      handle_blacklisted?(username) ->
        {:error, :blacklisted}

      handle_allowed?(username) ->
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

      true ->
        github_id_str = to_string(github_id)
        display_name = name || username

        upsert_join_request(%{
          github_id: github_id_str,
          github_username: username,
          github_avatar_url: avatar_url,
          display_name: display_name
        })

        {:error, :join_requested}
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

  # ---------------------------------------------------------------------------
  # Blacklisted GitHub Handles
  # ---------------------------------------------------------------------------

  @doc "Returns all blacklisted GitHub handles."
  def list_blacklisted_handles do
    BlacklistedGithubHandle
    |> order_by([h], asc: h.handle)
    |> Repo.all()
  end

  @doc "Gets a single blacklisted handle by id. Raises if not found."
  def get_blacklisted_handle!(id), do: Repo.get!(BlacklistedGithubHandle, id)

  @doc "Creates a blacklisted GitHub handle."
  def create_blacklisted_handle(attrs \\ %{}) do
    %BlacklistedGithubHandle{}
    |> BlacklistedGithubHandle.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Deletes a blacklisted GitHub handle."
  def delete_blacklisted_handle(%BlacklistedGithubHandle{} = handle) do
    Repo.delete(handle)
  end

  @doc "Returns an `%Ecto.Changeset{}` for tracking blacklisted handle changes."
  def change_blacklisted_handle(%BlacklistedGithubHandle{} = handle, attrs \\ %{}) do
    BlacklistedGithubHandle.changeset(handle, attrs)
  end

  @doc "Returns `true` if `username` is on the blacklist (case-insensitive)."
  def handle_blacklisted?(username) do
    normalized = String.downcase(username)

    BlacklistedGithubHandle
    |> where([h], fragment("lower(?)", h.handle) == ^normalized)
    |> Repo.exists?()
  end

  # ---------------------------------------------------------------------------
  # Join Requests
  # ---------------------------------------------------------------------------

  @doc "Returns all join requests, ordered by inserted_at desc."
  def list_join_requests do
    JoinRequest
    |> order_by([j], desc: j.inserted_at)
    |> Repo.all()
  end

  @doc "Returns pending join requests."
  def list_pending_join_requests do
    JoinRequest
    |> where([j], j.status == :pending)
    |> order_by([j], desc: j.inserted_at)
    |> Repo.all()
  end

  @doc "Gets a single join request by id. Raises if not found."
  def get_join_request!(id), do: Repo.get!(JoinRequest, id)

  @doc "Upserts a join request (insert or update based on github_id)."
  def upsert_join_request(attrs) do
    github_id = attrs[:github_id] || attrs["github_id"]

    case Repo.get_by(JoinRequest, github_id: github_id) do
      nil ->
        %JoinRequest{}
        |> JoinRequest.changeset(attrs)
        |> Repo.insert()

      existing ->
        existing
        |> JoinRequest.changeset(Map.put(attrs, :status, :pending))
        |> Repo.update()
    end
  end

  @doc """
  Approves a join request: creates the member account and marks the request
  as approved.
  """
  def approve_join_request(%JoinRequest{} = request) do
    Repo.transaction(fn ->
      {:ok, member} =
        %Member{}
        |> Member.github_oauth_changeset(%{
          github_id: request.github_id,
          github_username: request.github_username,
          github_avatar_url: request.github_avatar_url,
          display_name: request.display_name || request.github_username
        })
        |> Repo.insert()

      request
      |> JoinRequest.changeset(%{status: :approved})
      |> Repo.update!()

      member
    end)
  end

  @doc """
  Denies a join request and optionally adds the handle to the blacklist.
  """
  def deny_join_request(%JoinRequest{} = request, blacklist? \\ false) do
    Repo.transaction(fn ->
      request
      |> JoinRequest.changeset(%{status: :denied})
      |> Repo.update!()

      if blacklist? do
        %BlacklistedGithubHandle{}
        |> BlacklistedGithubHandle.changeset(%{handle: request.github_username})
        |> Repo.insert(on_conflict: :nothing)
      end

      :ok
    end)
  end
end
