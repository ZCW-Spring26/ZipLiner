import Config

config :zip_liner, ZipLiner.Repo,
  database: Path.expand("../zipliner_dev.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :zip_liner, ZipLinerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_secret_key_base_replace_in_production_this_is_64_chars_long!!",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:zip_liner, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:zip_liner, ~w(--watch)]}
  ]

config :zip_liner, ZipLinerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/zip_liner_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :zip_liner, :github_oauth,
  client_id: System.get_env("GITHUB_CLIENT_ID", "dev_client_id"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET", "dev_client_secret")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID", "dev_client_id"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET", "dev_client_secret")

config :logger, level: :debug

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view, :debug_heex_annotations, true

config :zip_liner, dev_routes: true
