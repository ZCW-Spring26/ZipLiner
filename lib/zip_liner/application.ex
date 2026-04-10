defmodule ZipLiner.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ZipLinerWeb.Telemetry,
      ZipLiner.Repo,
      {Phoenix.PubSub, name: ZipLiner.PubSub},
      {Finch, name: ZipLiner.Finch},
      ZipLinerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: ZipLiner.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ZipLinerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
