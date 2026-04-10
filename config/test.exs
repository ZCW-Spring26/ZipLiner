import Config

config :zip_liner, ZipLiner.Repo,
  database: Path.expand("../zipliner_test.db", Path.dirname(__ENV__.file)),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :zip_liner, ZipLinerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_replace_in_production_this_is_64_chars_long!",
  server: false

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "test_client_id",
  client_secret: "test_client_secret"

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
