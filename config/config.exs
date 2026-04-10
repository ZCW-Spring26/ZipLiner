import Config

config :zip_liner,
  ecto_repos: [ZipLiner.Repo],
  generators: [timestamp_type: :utc_datetime]

config :zip_liner, ZipLinerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ZipLinerWeb.ErrorHTML, json: ZipLinerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ZipLiner.PubSub,
  live_view: [signing_salt: "ziplinersalt"]

config :zip_liner, ZipLiner.Mailer, adapter: Swoosh.Adapters.Local

config :esbuild,
  version: "0.17.11",
  zip_liner: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.3.2",
  zip_liner: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email,read:user"]}
  ]

import_config "#{config_env()}.exs"
