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

    # :show is intentionally omitted here — it is defined in a separate public scope
    # below so that both authenticated and unauthenticated visitors can access it.
    # That scope is placed AFTER this one so that GET /articles/new is matched here
    # first, not treated as :id = "new".
    # Access control (private vs public visibility) is enforced inside the action.
    resources "/articles", ArticleController, only: [:index, :new, :create, :delete]
    post "/articles/:article_id/comments", ArticleCommentController, :create
    delete "/articles/:article_id/comments/:id", ArticleCommentController, :delete
  end

  # ---------------------------------------------------------------------------
  # Public article show — must be declared AFTER authenticated routes so that
  # GET /articles/new is matched by the authenticated :new action above and
  # not caught here as :id = "new".
  # Private articles redirect unauthenticated visitors to sign-in.
  # ---------------------------------------------------------------------------

  scope "/", ZipLinerWeb do
    pipe_through :browser

    get "/articles/:id", ArticleController, :show
  end

  scope "/", ZipLinerWeb do
    pipe_through [:browser, :require_auth]

    resources "/forums", ForumController, only: [:index, :new, :create, :show, :edit, :update, :delete]
    post "/forums/:forum_id/comments", ForumCommentController, :create
    patch "/forums/:forum_id/comments/:id", ForumCommentController, :update
    delete "/forums/:forum_id/comments/:id", ForumCommentController, :delete

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
    resources "/allowed_handles", AllowedHandleController, only: [:index, :create, :delete]
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
