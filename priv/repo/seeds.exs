# Seeds file for ZipLiner
# Run with: mix run priv/repo/seeds.exs

alias ZipLiner.Accounts

# Create a sample cohort
case Accounts.create_cohort(%{
       name: "Spring 2026",
       start_date: ~D[2026-01-05],
       graduation_date: ~D[2026-04-04]
     }) do
  {:ok, cohort} ->
    IO.puts("Created cohort: #{cohort.name}")

  {:error, changeset} ->
    IO.inspect(changeset.errors, label: "Error creating cohort")
end
