import Config

config :zip_liner, ZipLiner.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")
