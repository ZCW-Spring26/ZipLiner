import Config

# Database path is configured at runtime via the DATABASE_PATH environment
# variable in config/runtime.exs to allow flexible deployment (e.g. Docker).
config :zip_liner, ZipLiner.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")
