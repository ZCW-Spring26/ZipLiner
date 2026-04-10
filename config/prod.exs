import Config

config :zip_liner, ZipLiner.Repo,
  database: System.get_env("DATABASE_PATH") || "zipliner_prod.db",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")
