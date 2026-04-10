defmodule ZipLinerWeb.Router do
  use ZipLinerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ZipLinerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ZipLinerWeb.Plugs.LoadCurrentMember
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_auth do
    plug ZipLinerWeb.Plugs.RequireAuth
  end

  # ---------------------------------------------------------------------------
  # Public routes (no authentication required)
  # ---------------------------------------------------------------------------

  scope "/", ZipLinerWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # ---------------------------------------------------------------------------
  # GitHub OAuth routes
  # ---------------------------------------------------------------------------

  scope "/auth", ZipLinerWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :logout
  end

  # ---------------------------------------------------------------------------
  # Authenticated routes
  # ---------------------------------------------------------------------------

  scope "/", ZipLinerWeb do
    pipe_through [:browser, :require_auth]

    get "/feed", FeedController, :index

    resources "/members", MemberController, only: [:index, :show, :edit, :update]
    post "/members/:id/connect", MemberController, :connect
    post "/members/:id/accept_connection", MemberController, :accept_connection

    resources "/projects", ProjectController, except: [:delete]
    delete "/projects/:id", ProjectController, :delete

    resources "/posts", PostController, only: [:create, :show, :delete]
    post "/posts/:id/react", PostController, :react
    post "/posts/:id/replies", PostController, :reply

    resources "/channels", ChannelController, only: [:index, :show]

    get "/messages", MessageController, :index
    get "/messages/:member_id", MessageController, :show
    post "/messages/:member_id", MessageController, :create

    get "/settings", SettingsController, :edit
    put "/settings", SettingsController, :update
  end

  # ---------------------------------------------------------------------------
  # Admin routes
  # ---------------------------------------------------------------------------

  scope "/admin", ZipLinerWeb.Admin, as: :admin do
    pipe_through [:browser, :require_auth]

    resources "/cohorts", CohortController
    resources "/members", MemberController, only: [:index, :show, :edit, :update, :delete]
  end

  # ---------------------------------------------------------------------------
  # Dev tools
  # ---------------------------------------------------------------------------

  if Application.compile_env(:zip_liner, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ZipLinerWeb.Telemetry
    end
  end
end
