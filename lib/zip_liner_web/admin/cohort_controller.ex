defmodule ZipLinerWeb.Admin.CohortController do
  use ZipLinerWeb, :controller

  alias ZipLiner.Accounts
  alias ZipLiner.Accounts.Cohort

  def index(conn, _params) do
    cohorts = Accounts.list_cohorts()
    render(conn, :index, cohorts: cohorts)
  end

  def new(conn, _params) do
    changeset = Accounts.change_cohort(%Cohort{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"cohort" => cohort_params}) do
    case Accounts.create_cohort(cohort_params) do
      {:ok, cohort} ->
        conn
        |> put_flash(:info, "Cohort #{cohort.name} created.")
        |> redirect(to: ~p"/admin/cohorts/#{cohort.id}")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cohort = Accounts.get_cohort!(id)
    render(conn, :show, cohort: cohort)
  end

  def edit(conn, %{"id" => id}) do
    cohort = Accounts.get_cohort!(id)
    changeset = Accounts.change_cohort(cohort)
    render(conn, :edit, cohort: cohort, changeset: changeset)
  end

  def update(conn, %{"id" => id, "cohort" => cohort_params}) do
    cohort = Accounts.get_cohort!(id)

    case Accounts.update_cohort(cohort, cohort_params) do
      {:ok, updated_cohort} ->
        conn
        |> put_flash(:info, "Cohort updated.")
        |> redirect(to: ~p"/admin/cohorts/#{updated_cohort.id}")

      {:error, changeset} ->
        render(conn, :edit, cohort: cohort, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cohort = Accounts.get_cohort!(id)
    ZipLiner.Repo.delete!(cohort)

    conn
    |> put_flash(:info, "Cohort deleted.")
    |> redirect(to: ~p"/admin/cohorts")
  end
end
