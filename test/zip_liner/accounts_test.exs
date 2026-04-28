defmodule ZipLiner.AccountsTest do
  use ZipLiner.DataCase

  alias ZipLiner.Accounts
  import ZipLiner.AccountsFixtures

  describe "cohorts" do
    test "create_cohort/1 creates a cohort with valid attrs" do
      attrs = cohort_attrs()
      assert {:ok, cohort} = Accounts.create_cohort(attrs)
      assert cohort.name == attrs.name
    end

    test "create_cohort/1 requires a name" do
      assert {:error, changeset} = Accounts.create_cohort(%{start_date: ~D[2024-01-01]})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "list_cohorts/0 returns all cohorts" do
      cohort = cohort_fixture()
      cohorts = Accounts.list_cohorts()
      assert Enum.any?(cohorts, fn c -> c.id == cohort.id end)
    end

    test "get_cohort!/1 returns the cohort with given id" do
      cohort = cohort_fixture()
      assert Accounts.get_cohort!(cohort.id).id == cohort.id
    end
  end

  describe "members" do
    test "create_member/1 creates a member with valid attrs" do
      attrs = member_attrs()
      assert {:ok, member} = Accounts.create_member(attrs)
      assert member.github_username == attrs.github_username
    end

    test "create_member/1 requires github_id" do
      assert {:error, changeset} =
               Accounts.create_member(%{github_username: "foo", display_name: "Foo"})

      assert %{github_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_member/1 enforces unique github_id" do
      attrs = member_attrs()
      {:ok, _first} = Accounts.create_member(attrs)

      assert {:error, changeset} =
               Accounts.create_member(%{attrs | github_username: "other_user"})

      assert %{github_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "find_or_create_from_github/1 creates a new member on first login" do
      github_data = %{
        "id" => 999_001,
        "login" => "newuser",
        "name" => "New User",
        "avatar_url" => "https://avatars.githubusercontent.com/u/999001"
      }

      assert {:ok, member} = Accounts.find_or_create_from_github(github_data)
      assert member.github_username == "newuser"
      assert member.display_name == "New User"
    end

    test "find_or_create_from_github/1 updates an existing member on subsequent login" do
      github_data = %{
        "id" => 999_002,
        "login" => "existinguser",
        "name" => "Existing User",
        "avatar_url" => "https://avatars.githubusercontent.com/u/999002"
      }

      {:ok, first} = Accounts.find_or_create_from_github(github_data)

      updated_data = %{github_data | "name" => "Updated Name"}
      {:ok, second} = Accounts.find_or_create_from_github(updated_data)

      assert first.id == second.id
      assert second.display_name == "Updated Name"
    end

    test "get_member_by_github_id/1 returns nil for unknown id" do
      assert nil == Accounts.get_member_by_github_id("nonexistent")
    end

    test "deprovision_member/1 sets status to deprovisioned" do
      member = member_fixture()
      {:ok, deprovisioned} = Accounts.deprovision_member(member)
      assert deprovisioned.status == :deprovisioned
    end

    test "update_member/2 updates allowed fields" do
      member = member_fixture()
      {:ok, updated} = Accounts.update_member(member, %{bio: "Hello world"})
      assert updated.bio == "Hello world"
    end

    test "update_member/2 updates theme_preference" do
      member = member_fixture()
      {:ok, updated} = Accounts.update_member(member, %{theme_preference: :dark})
      assert updated.theme_preference == :dark
    end

    test "update_member/2 saves a valid linkedin_url" do
      member = member_fixture()
      {:ok, updated} = Accounts.update_member(member, %{linkedin_url: "https://www.linkedin.com/in/testuser"})
      assert updated.linkedin_url == "https://www.linkedin.com/in/testuser"
    end

    test "update_member/2 rejects an invalid linkedin_url" do
      member = member_fixture()
      assert {:error, changeset} = Accounts.update_member(member, %{linkedin_url: "not-a-url"})
      assert %{linkedin_url: ["must be a valid http or https URL"]} = errors_on(changeset)
    end

    test "update_member/2 accepts nil linkedin_url" do
      member = member_fixture()
      {:ok, updated} = Accounts.update_member(member, %{linkedin_url: nil})
      assert updated.linkedin_url == nil
    end

    test "change_member/2 returns a changeset" do
      member = member_fixture()
      assert %Ecto.Changeset{} = Accounts.change_member(member)
    end

    test "find_or_create_from_github/1 grants admin to kristofer" do
      github_data = %{
        "id" => 1,
        "login" => "kristofer",
        "name" => "Kristofer",
        "avatar_url" => "https://avatars.githubusercontent.com/u/1"
      }

      assert {:ok, member} = Accounts.find_or_create_from_github(github_data)
      assert member.is_admin == true
    end

    test "find_or_create_from_github/1 does not grant admin to regular users" do
      github_data = %{
        "id" => 999_003,
        "login" => "regularuser",
        "name" => "Regular User",
        "avatar_url" => "https://avatars.githubusercontent.com/u/999003"
      }

      assert {:ok, member} = Accounts.find_or_create_from_github(github_data)
      assert member.is_admin == false
    end
  end

  describe "allowed_github_handles" do
    test "list_allowed_handles/0 returns all handles ordered by handle" do
      {:ok, _} = Accounts.create_allowed_handle(%{handle: "zebra"})
      {:ok, _} = Accounts.create_allowed_handle(%{handle: "alpha"})

      handles = Accounts.list_allowed_handles()
      handle_strings = Enum.map(handles, & &1.handle)
      assert handle_strings == Enum.sort(handle_strings)
    end

    test "create_allowed_handle/1 creates a handle with valid attrs" do
      assert {:ok, h} = Accounts.create_allowed_handle(%{handle: "octocat"})
      assert h.handle == "octocat"
    end

    test "create_allowed_handle/1 normalises handle to lowercase" do
      assert {:ok, h} = Accounts.create_allowed_handle(%{handle: "OctoCAT"})
      assert h.handle == "octocat"
    end

    test "create_allowed_handle/1 requires a handle" do
      assert {:error, changeset} = Accounts.create_allowed_handle(%{})
      assert %{handle: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_allowed_handle/1 enforces uniqueness" do
      {:ok, _} = Accounts.create_allowed_handle(%{handle: "dupuser"})
      assert {:error, changeset} = Accounts.create_allowed_handle(%{handle: "dupuser"})
      assert %{handle: ["has already been taken"]} = errors_on(changeset)
    end

    test "delete_allowed_handle/1 removes the handle" do
      {:ok, h} = Accounts.create_allowed_handle(%{handle: "todelete"})
      assert {:ok, _} = Accounts.delete_allowed_handle(h)
      assert Accounts.list_allowed_handles() |> Enum.all?(fn e -> e.id != h.id end)
    end

    test "handle_allowed?/1 returns true when whitelist is empty" do
      assert Accounts.handle_allowed?("anyone")
    end

    test "handle_allowed?/1 returns true for listed handle" do
      {:ok, _} = Accounts.create_allowed_handle(%{handle: "alloweduser"})
      assert Accounts.handle_allowed?("alloweduser")
    end

    test "handle_allowed?/1 is case-insensitive" do
      {:ok, _} = Accounts.create_allowed_handle(%{handle: "alloweduser"})
      assert Accounts.handle_allowed?("AllowedUser")
    end

    test "handle_allowed?/1 returns false for unlisted handle when whitelist has entries" do
      {:ok, _} = Accounts.create_allowed_handle(%{handle: "alloweduser"})
      refute Accounts.handle_allowed?("notallowed")
    end

    test "find_or_create_from_github/1 returns :join_requested when handle not on whitelist" do
      {:ok, _} = Accounts.create_allowed_handle(%{handle: "allowedonly"})

      github_data = %{
        "id" => 999_004,
        "login" => "blockeduser",
        "name" => "Blocked User",
        "avatar_url" => "https://avatars.githubusercontent.com/u/999004"
      }

      assert {:error, :join_requested} = Accounts.find_or_create_from_github(github_data)
    end

    test "find_or_create_from_github/1 succeeds when handle is whitelisted" do
      {:ok, _} = Accounts.create_allowed_handle(%{handle: "alloweduser"})

      github_data = %{
        "id" => 999_005,
        "login" => "alloweduser",
        "name" => "Allowed User",
        "avatar_url" => "https://avatars.githubusercontent.com/u/999005"
      }

      assert {:ok, member} = Accounts.find_or_create_from_github(github_data)
      assert member.github_username == "alloweduser"
    end
  end

  describe "blacklisted_github_handles" do
    test "create_blacklisted_handle/1 creates a handle" do
      assert {:ok, h} = Accounts.create_blacklisted_handle(%{handle: "badactor"})
      assert h.handle == "badactor"
    end

    test "create_blacklisted_handle/1 normalises handle to lowercase" do
      assert {:ok, h} = Accounts.create_blacklisted_handle(%{handle: "BadActor"})
      assert h.handle == "badactor"
    end

    test "create_blacklisted_handle/1 requires a handle" do
      assert {:error, changeset} = Accounts.create_blacklisted_handle(%{})
      assert %{handle: ["can't be blank"]} = errors_on(changeset)
    end

    test "list_blacklisted_handles/0 returns all handles ordered by handle" do
      {:ok, _} = Accounts.create_blacklisted_handle(%{handle: "zebra"})
      {:ok, _} = Accounts.create_blacklisted_handle(%{handle: "alpha"})

      handles = Accounts.list_blacklisted_handles()
      handle_strings = Enum.map(handles, & &1.handle)
      assert handle_strings == Enum.sort(handle_strings)
    end

    test "delete_blacklisted_handle/1 removes the handle" do
      {:ok, h} = Accounts.create_blacklisted_handle(%{handle: "todelete"})
      assert {:ok, _} = Accounts.delete_blacklisted_handle(h)
      assert Accounts.list_blacklisted_handles() |> Enum.all?(fn e -> e.id != h.id end)
    end

    test "handle_blacklisted?/1 returns true for blacklisted handle" do
      {:ok, _} = Accounts.create_blacklisted_handle(%{handle: "badguy"})
      assert Accounts.handle_blacklisted?("badguy")
    end

    test "handle_blacklisted?/1 is case-insensitive" do
      {:ok, _} = Accounts.create_blacklisted_handle(%{handle: "badguy"})
      assert Accounts.handle_blacklisted?("BadGuy")
    end

    test "handle_blacklisted?/1 returns false for non-blacklisted handle" do
      refute Accounts.handle_blacklisted?("normaluser")
    end

    test "find_or_create_from_github/1 returns :blacklisted for blacklisted handles" do
      {:ok, _} = Accounts.create_blacklisted_handle(%{handle: "spammer"})

      github_data = %{
        "id" => 999_010,
        "login" => "spammer",
        "name" => "Spammer",
        "avatar_url" => "https://avatars.githubusercontent.com/u/999010"
      }

      assert {:error, :blacklisted} = Accounts.find_or_create_from_github(github_data)
    end
  end

  describe "join_requests" do
    test "upsert_join_request/1 creates a pending join request" do
      attrs = %{
        github_id: "888001",
        github_username: "newapplicant",
        display_name: "New Applicant"
      }

      {:ok, request} = Accounts.upsert_join_request(attrs)
      assert request.github_username == "newapplicant"
      assert request.status == :pending
    end

    test "upsert_join_request/1 updates an existing request" do
      attrs = %{github_id: "888002", github_username: "applicant2", display_name: "A"}
      {:ok, first} = Accounts.upsert_join_request(attrs)
      {:ok, second} = Accounts.upsert_join_request(%{attrs | display_name: "B"})

      assert first.id == second.id
      assert second.display_name == "B"
    end

    test "list_pending_join_requests/0 returns only pending requests" do
      {:ok, r1} = Accounts.upsert_join_request(%{github_id: "888003", github_username: "u3"})
      {:ok, r2} = Accounts.upsert_join_request(%{github_id: "888004", github_username: "u4"})
      Accounts.deny_join_request(r2)

      pending = Accounts.list_pending_join_requests()
      pending_ids = Enum.map(pending, & &1.id)
      assert r1.id in pending_ids
      refute r2.id in pending_ids
    end

    test "approve_join_request/1 creates a member and marks request approved" do
      {:ok, request} =
        Accounts.upsert_join_request(%{
          github_id: "888005",
          github_username: "approveduser",
          display_name: "Approved User"
        })

      assert {:ok, member} = Accounts.approve_join_request(request)
      assert member.github_username == "approveduser"

      updated = Accounts.get_join_request!(request.id)
      assert updated.status == :approved
    end

    test "deny_join_request/1 marks request denied" do
      {:ok, request} =
        Accounts.upsert_join_request(%{
          github_id: "888006",
          github_username: "denieduser",
          display_name: "Denied User"
        })

      assert {:ok, :ok} = Accounts.deny_join_request(request)
      updated = Accounts.get_join_request!(request.id)
      assert updated.status == :denied
    end

    test "deny_join_request/2 adds to blacklist when blacklist? is true" do
      {:ok, request} =
        Accounts.upsert_join_request(%{
          github_id: "888007",
          github_username: "blacklisteduser",
          display_name: "Blacklisted User"
        })

      assert {:ok, :ok} = Accounts.deny_join_request(request, true)
      assert Accounts.handle_blacklisted?("blacklisteduser")
    end
  end
end
