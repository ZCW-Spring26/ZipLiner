defmodule ZipLiner.Repo do
  use Ecto.Repo,
    otp_app: :zip_liner,
    adapter: Ecto.Adapters.SQLite3
end
