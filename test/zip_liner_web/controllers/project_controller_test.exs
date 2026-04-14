defmodule ZipLinerWeb.ProjectControllerTest do
  use ZipLinerWeb.ConnCase

  alias ZipLiner.AccountsFixtures
  alias ZipLiner.ProjectsFixtures

  describe "index" do
    setup :log_in_member

    test "lists all projects", %{conn: conn} do
      conn = get(conn, ~p"/projects")
      assert html_response(conn, 200) =~ "Projects"
    end

    test "lists projects filtered by owner", %{conn: conn, member: member} do
      ProjectsFixtures.project_fixture(member.id, %{name: "My Special Project"})
      conn = get(conn, ~p"/projects?owner_id=#{member.id}")
      assert html_response(conn, 200) =~ "My Special Project"
    end
  end

  describe "show" do
    setup :log_in_member

    test "shows project", %{conn: conn, member: member} do
      project = ProjectsFixtures.project_fixture(member.id, %{name: "Visible Project"})
      conn = get(conn, ~p"/projects/#{project.id}")
      assert html_response(conn, 200) =~ "Visible Project"
    end

    test "owner sees edit and delete buttons", %{conn: conn, member: member} do
      project = ProjectsFixtures.project_fixture(member.id)
      conn = get(conn, ~p"/projects/#{project.id}")
      assert html_response(conn, 200) =~ "Edit"
      assert html_response(conn, 200) =~ "Delete"
    end

    test "non-owner does not see edit and delete buttons", %{conn: conn, member: _member} do
      other = AccountsFixtures.member_fixture()
      project = ProjectsFixtures.project_fixture(other.id)
      conn = get(conn, ~p"/projects/#{project.id}")
      refute html_response(conn, 200) =~ "Edit"
      refute html_response(conn, 200) =~ "Delete"
    end

    test "admin sees edit and delete buttons on any project", %{conn: conn} do
      admin = AccountsFixtures.member_fixture(%{is_admin: true})
      other = AccountsFixtures.member_fixture()
      project = ProjectsFixtures.project_fixture(other.id)

      conn = log_in_member(conn, admin)
      conn = get(conn, ~p"/projects/#{project.id}")
      assert html_response(conn, 200) =~ "Edit"
      assert html_response(conn, 200) =~ "Delete"
    end
  end

  describe "edit" do
    setup :log_in_member

    test "owner can access edit page", %{conn: conn, member: member} do
      project = ProjectsFixtures.project_fixture(member.id)
      conn = get(conn, ~p"/projects/#{project.id}/edit")
      assert html_response(conn, 200) =~ "Edit Project"
    end

    test "non-owner is redirected with error", %{conn: conn} do
      other = AccountsFixtures.member_fixture()
      project = ProjectsFixtures.project_fixture(other.id)
      conn = get(conn, ~p"/projects/#{project.id}/edit")
      assert redirected_to(conn) == ~p"/projects/#{project.id}"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "only edit your own"
    end

    test "admin can access edit page for any project", %{conn: conn} do
      admin = AccountsFixtures.member_fixture(%{is_admin: true})
      other = AccountsFixtures.member_fixture()
      project = ProjectsFixtures.project_fixture(other.id)

      conn = log_in_member(conn, admin)
      conn = get(conn, ~p"/projects/#{project.id}/edit")
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "delete" do
    setup :log_in_member

    test "owner can delete their project", %{conn: conn, member: member} do
      project = ProjectsFixtures.project_fixture(member.id)
      conn = delete(conn, ~p"/projects/#{project.id}")
      assert redirected_to(conn) == ~p"/projects"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "deleted"
    end

    test "non-owner cannot delete a project", %{conn: conn} do
      other = AccountsFixtures.member_fixture()
      project = ProjectsFixtures.project_fixture(other.id)
      conn = delete(conn, ~p"/projects/#{project.id}")
      assert redirected_to(conn) == ~p"/projects"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "only delete your own"
    end

    test "admin can delete any project", %{conn: conn} do
      admin = AccountsFixtures.member_fixture(%{is_admin: true})
      other = AccountsFixtures.member_fixture()
      project = ProjectsFixtures.project_fixture(other.id)

      conn = log_in_member(conn, admin)
      conn = delete(conn, ~p"/projects/#{project.id}")
      assert redirected_to(conn) == ~p"/projects"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "deleted"
    end
  end

  describe "unauthenticated access" do
    test "redirects to home when not logged in", %{conn: conn} do
      conn = get(conn, ~p"/projects")
      assert redirected_to(conn) == ~p"/"
    end

    test "redirects to home when accessing project without login", %{conn: conn} do
      member = AccountsFixtures.member_fixture()
      project = ProjectsFixtures.project_fixture(member.id)
      conn = get(conn, ~p"/projects/#{project.id}")
      assert redirected_to(conn) == ~p"/"
    end
  end
end
