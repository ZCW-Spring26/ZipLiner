# ZipLiner — Architecture & Educational Overview

This document is written for developers who are new to the project or to the
Elixir/Phoenix ecosystem. It covers:

1. [A brief introduction to Elixir](#1-elixir--the-beam)
2. [Project architecture and directory structure](#2-project-architecture)
3. [How an HTTP request travels through the application](#3-http-requestresponse-lifecycle)
4. [Middleware patterns (Plug pipelines)](#4-middleware--plug-pipelines)
5. [Authentication flow (GitHub OAuth)](#5-authentication-flow)
6. [The data model](#6-data-model)
7. [The frontend layer (HTMX + Bootstrap + HEEx)](#7-frontend-layer)

---

## 1. Elixir & the BEAM

### What is Elixir?

[Elixir](https://elixir-lang.org/) is a functional, dynamically typed programming
language that runs on the **BEAM** — the Erlang virtual machine. It was created in
2012 and borrows Erlang's battle-tested concurrency model while adding a modern
syntax, macro system, and tooling.

Key characteristics:

| Feature | What it means in practice |
|---|---|
| **Functional** | Data is immutable; functions transform values rather than mutating state. |
| **Pattern matching** | `case`, `with`, and function heads match on the _shape_ of data, eliminating many `if`/`else` chains. |
| **Processes** | Lightweight concurrency units (not OS threads). A busy server can run millions simultaneously. |
| **Fault tolerance** | Supervisors restart crashed processes automatically — the "let it crash" philosophy. |
| **Hot code reloading** | Code can be swapped at runtime without restarting the server. |

### What is Phoenix?

[Phoenix](https://phoenixframework.org/) is the primary web framework for Elixir,
analogous to Rails (Ruby), Django (Python), or Spring (Java). It adds:

- **Routing** — declarative HTTP route definitions
- **Controllers** — handle request/response logic
- **Views/Components** — render HTML via HEEx templates (`.html.heex`)
- **Channels** — real-time WebSocket communication
- **LiveView** — server-rendered interactive UIs over WebSockets (used optionally in ZipLiner)

### Mix — the build tool

`mix` is Elixir's built-in task runner and dependency manager (similar to npm or Cargo).

```bash
mix deps.get          # install dependencies
mix ecto.migrate      # run database migrations
mix phx.server        # start the development web server
mix test              # run tests
mix assets.build      # compile CSS + JS assets
```

---

## 2. Project Architecture

ZipLiner follows the standard **Phoenix umbrella-less** project layout. There is a
single OTP application (`zip_liner`) with two logical sub-layers.

```
lib/
├── zip_liner/               ← "domain" layer — pure business logic
│   ├── accounts/            # Member & Cohort schemas + context module
│   ├── social/              # Connections, Posts, Channels, Reactions, Replies, DMs
│   ├── projects/            # Project Showcase schemas + context
│   ├── notifications/       # In-app notification schema + context
│   ├── application.ex       # OTP Application — starts the supervision tree
│   ├── mailer.ex            # Email delivery (Swoosh)
│   └── repo.ex              # Ecto repository (database interface)
│
└── zip_liner_web/           ← "web" layer — HTTP, templates, routing
    ├── admin/               # Admin-only controllers (Cohorts, Members)
    ├── components/          # Shared HEEx components and layout files
    ├── controllers/         # One controller per resource/feature
    ├── plugs/               # Custom Plug middleware
    ├── endpoint.ex          # Phoenix Endpoint — the outermost request handler
    ├── router.ex            # Route definitions and pipeline composition
    ├── gettext.ex           # Internationalisation helpers
    └── telemetry.ex         # Metrics and instrumentation
```

### The context pattern

Phoenix encourages grouping related schemas and functions into **context modules**
(e.g., `ZipLiner.Accounts`, `ZipLiner.Social`). Controllers never query the
database directly — they call context functions, which keep business rules in one
place and make the code easier to test.

```
Controller  →  Context module  →  Ecto schema / Repo
(HTTP layer)    (business logic)   (database layer)
```

---

## 3. HTTP Request/Response Lifecycle

When a browser sends `GET /feed`, the request passes through several layers in order:

```
Browser
  │
  ▼
ZipLinerWeb.Endpoint        (lib/zip_liner_web/endpoint.ex)
  │  Plug.Static             — serves files from priv/static
  │  Plug.RequestId          — assigns a unique ID to every request
  │  Plug.Telemetry          — emits timing events
  │  Plug.Parsers            — decodes JSON / multipart / URL-encoded bodies
  │  Plug.MethodOverride     — allows DELETE/PUT via hidden _method field
  │  Plug.Head               — converts HEAD requests to GET
  │  Plug.Session            — loads and writes the cookie session
  │
  ▼
ZipLinerWeb.Router          (lib/zip_liner_web/router.ex)
  │  pipe_through :browser   — runs the :browser pipeline (see §4)
  │  pipe_through :require_auth — (for protected routes only)
  │
  ▼
ZipLinerWeb.FeedController  (lib/zip_liner_web/controllers/feed_controller.ex)
  │  def index(conn, params) — business logic, calls context functions
  │
  ▼
ZipLinerWeb.FeedHTML        (lib/zip_liner_web/controllers/feed_html/)
  │  index.html.heex         — HEEx template rendered to an HTML string
  │
  ▼
Browser receives HTML response
```

### The `conn` struct

The central data structure in Phoenix is `Plug.Conn`. It represents the full
state of an HTTP connection — request headers, body, session, assigns, response
status, and response headers. Every plug receives a `conn`, optionally transforms
it, and returns the (possibly modified) `conn`.

```elixir
# Example: reading from conn
conn.method          # "GET"
conn.request_path    # "/feed"
conn.assigns         # %{current_member: %Member{...}}

# Example: writing to conn
conn
|> put_status(200)
|> put_resp_header("content-type", "text/html")
|> send_resp(200, html_body)
```

---

## 4. Middleware — Plug Pipelines

### What is a Plug?

A **Plug** is any module or function that:

1. Accepts a `Plug.Conn` and options.
2. Returns a (potentially modified) `Plug.Conn`.

This uniform interface lets plugs be composed into **pipelines** — ordered chains
where each plug transforms the connection before passing it to the next.

### Built-in pipelines in ZipLiner

**`:browser` pipeline** — applied to every HTML request:

```elixir
pipeline :browser do
  plug :accepts, ["html"]              # reject non-HTML requests
  plug :fetch_session                  # load cookie session data
  plug :fetch_live_flash               # load flash messages
  plug :put_root_layout, html: {ZipLinerWeb.Layouts, :root}  # set layout
  plug :protect_from_forgery           # CSRF protection
  plug :put_secure_browser_headers     # add X-Frame-Options, CSP, etc.
  plug ZipLinerWeb.Plugs.LoadCurrentMember  # custom plug — see below
end
```

**`:require_auth` pipeline** — added on top of `:browser` for protected routes:

```elixir
pipeline :require_auth do
  plug ZipLinerWeb.Plugs.RequireAuth   # redirect if not logged in
end
```

**`:api` pipeline** — for JSON API endpoints (not yet widely used):

```elixir
pipeline :api do
  plug :accepts, ["json"]
end
```

### Custom plugs

#### `LoadCurrentMember`

`lib/zip_liner_web/plugs/load_current_member.ex`

Reads `:current_member_id` from the session and fetches the corresponding
`Member` record from the database, placing it in `conn.assigns.current_member`.
If the session contains a stale ID (e.g., the member was deleted), the session
key is cleared and `current_member` is set to `nil`.

```elixir
def call(conn, _opts) do
  case get_session(conn, :current_member_id) do
    nil       -> assign(conn, :current_member, nil)
    member_id -> assign(conn, :current_member, Accounts.get_member!(member_id))
  end
end
```

#### `RequireAuth`

`lib/zip_liner_web/plugs/require_auth.ex`

Checks whether `conn.assigns.current_member` is set. If it is not, the plug
redirects to the home page and **halts** the pipeline (no further plugs or the
controller action run).

```elixir
def call(conn, _opts) do
  if conn.assigns[:current_member] do
    conn
  else
    conn
    |> put_flash(:error, "You must be signed in to access that page.")
    |> redirect(to: ~p"/")
    |> halt()
  end
end
```

---

## 5. Authentication Flow

ZipLiner uses **GitHub OAuth 2.0** via the
[Ueberauth](https://github.com/ueberauth/ueberauth) library.
LinkedIn credentials are stored as an optional profile field but are **not** used
for login.

### Step-by-step OAuth flow

```
1. User clicks "Sign in with GitHub"
   → browser navigates to GET /auth/github

2. AuthController.request/2 is called
   → Ueberauth redirects to github.com/login/oauth/authorize
   → GitHub asks the user to grant read:user access

3. GitHub redirects to GET /auth/github/callback?code=...
   → AuthController.callback/2 is called
   → Ueberauth exchanges the code for an access token
   → Ueberauth fetches the user's GitHub profile
   → conn.assigns.ueberauth_auth is populated

4. AuthController extracts github_id, username, avatar URL
   → Accounts.upsert_member_from_github/1 is called
     • if member exists  → return existing record
     • if new user       → insert a new Member row
   → :current_member_id is written to the session
   → user is redirected to /feed
```

### Session storage

The session is stored in a **signed cookie** (`_zip_liner_key`). The session only
contains a single integer — `:current_member_id`. The full `Member` struct is
loaded from the database on every request by `LoadCurrentMember`.

---

## 6. Data Model

ZipLiner uses **Ecto** — the standard Elixir database library — backed by
**SQLite3** (via `ecto_sqlite3`). Schemas are grouped into context modules that
mirror the project's domain areas.

### Entity Relationship Overview

```
Cohort ─────────────────────────────────────────────────────────────┐
  │ has_many                                                         │
  ▼                                                                  │ belongs_to
Member ──────────── has_many ────────── Post                         │
  │  │  │                                │ has_many                  │
  │  │  │                                ├── Reaction (member, post)  │
  │  │  │                                └── Reply   (author, post)   │
  │  │  │                                                             │
  │  │  ├── has_many ──────────── Connection (member_a, member_b)     │
  │  │  │                                                             │
  │  │  ├── has_many ──────────── Project                             │
  │  │  │                                                             │
  │  │  ├── has_many (as sender) ── DirectMessage                     │
  │  │  │   has_many (as recipient)                                   │
  │  │  │                                                             │
  │  │  └── has_many ──────────── Notification                        │
  │                                                                   │
Channel ────────── belongs_to Cohort ──────────────────────────────┘
  │ has_many
  └── Post
```

### Schemas

#### `Member` (`accounts/member.ex`)

The central entity representing a ZipCode student, alumni, or staff member.

| Field | Type | Notes |
|---|---|---|
| `github_id` | string | Unique — primary OAuth identifier |
| `github_username` | string | Unique |
| `github_avatar_url` | string | Profile picture URL |
| `linkedin_url` | string | Optional profile link |
| `display_name` | string | Max 100 chars |
| `bio` | string | Max 280 chars |
| `current_title` | string | Current job title |
| `employer` | string | |
| `location` | string | |
| `role` | enum | `student`, `alumni`, `instructor`, `staff`, `mentor`, `guest` |
| `status` | enum | `active`, `suspended`, `deprovisioned` |
| `open_to_opportunities` | boolean | Job-seeking flag |
| `skills` | string[] | Array of skill tags |
| `avatar_source` | enum | `github` or `linkedin` |
| `cohort_id` | FK → Cohort | |

---

#### `Cohort` (`accounts/cohort.ex`)

A ZipCode program cohort (e.g., "Spring 2026").

| Field | Type | Notes |
|---|---|---|
| `name` | string | Max 100 chars |
| `start_date` | date | |
| `graduation_date` | date | Optional |

---

#### `Connection` (`social/connection.ex`)

A bi-directional professional connection between two members.

| Field | Type | Notes |
|---|---|---|
| `member_id_a` | FK → Member | The member who sent the request |
| `member_id_b` | FK → Member | The recipient |
| `status` | enum | `pending`, `accepted` |

Uniqueness is enforced at the database level on `(member_id_a, member_id_b)`.

---

#### `Channel` (`social/channel.ex`)

A named channel that groups posts (similar to a Slack channel).

| Field | Type | Notes |
|---|---|---|
| `name` | string | Unique, max 100 chars |
| `type` | enum | `cohort`, `topic`, `staff`, `dm` |
| `description` | string | Max 500 chars |
| `cohort_id` | FK → Cohort | Optional — links cohort channels to a cohort |

---

#### `Post` (`social/post.ex`)

Content published into a channel.

| Field | Type | Notes |
|---|---|---|
| `type` | enum | `status`, `article`, `project_showcase`, `long_form`, `cohort_shoutout`, `job_signal` |
| `content` | string | Max length varies by type (300–10 000 chars) |
| `url` | string | Optional external link |
| `url_title` | string | Optional link preview title |
| `author_id` | FK → Member | |
| `channel_id` | FK → Channel | Optional |

---

#### `Reaction` (`social/reaction.ex`)

An emoji reaction a member adds to a post.

| Field | Type | Notes |
|---|---|---|
| `kind` | enum | `thumbs_up`, `fire`, `lightbulb`, `celebrate` |
| `post_id` | FK → Post | |
| `member_id` | FK → Member | |

A unique constraint on `(post_id, member_id, kind)` prevents duplicate reactions.

---

#### `Reply` (`social/reply.ex`)

A comment on a post.

| Field | Type | Notes |
|---|---|---|
| `content` | string | Max 1 000 chars |
| `post_id` | FK → Post | |
| `author_id` | FK → Member | |

---

#### `Project` (`projects/project.ex`)

A project that a member has built or is building.

| Field | Type | Notes |
|---|---|---|
| `name` | string | Max 80 chars |
| `tagline` | string | Max 120 chars |
| `description` | string | Max 800 chars |
| `status` | enum | `in_progress`, `completed`, `archived`, `looking_for_collaborators` |
| `repo_url` | string | Must be a valid http/https URL |
| `demo_url` | string | Must be a valid http/https URL |
| `tech_stack` | string[] | Array of technology names |
| `role` | string | Member's role on the project |
| `cohort_project` | boolean | Flag for group cohort projects |
| `owner_id` | FK → Member | |

---

#### `DirectMessage` (`social/direct_message.ex`)

A private message between two members.

| Field | Type | Notes |
|---|---|---|
| `content` | string | Max 5 000 chars |
| `sender_id` | FK → Member | |
| `recipient_id` | FK → Member | |
| `read_at` | utc_datetime | `nil` = unread |

---

#### `Notification` (`notifications/notification.ex`)

An in-app notification delivered to a member.

| Field | Type | Notes |
|---|---|---|
| `type` | enum | `connection_request`, `connection_accepted`, `mention`, `reply`, `reaction`, `introduction_request`, `staff_announcement`, `cohort_post` |
| `payload` | map (JSON) | Arbitrary metadata (e.g., `%{from_member_id: 42}`) |
| `read_at` | utc_datetime | `nil` = unread |
| `recipient_id` | FK → Member | |

---

## 7. Frontend Layer

### HEEx templates

Phoenix renders HTML via **HEEx** (HTML + Embedded Elixir) templates — files
ending in `.html.heex`. HEEx extends standard HTML with:

- `<%= expr %>` — embed an Elixir expression and include its return value in the HTML
- `<% expr %>` — execute an expression without including its return value
- `{expr}` — shorthand for embedding within attributes
- `<.component_name />` — call a function component defined in a module

Example snippet from a template:

```heex
<%= for post <- @posts do %>
  <div class="card mb-3">
    <p><%= post.content %></p>
    <span class="text-muted"><%= post.author.display_name %></span>
  </div>
<% end %>
```

Templates are **compiled** to Elixir functions at startup, making rendering very
fast with no file I/O at request time.

### HTMX

[HTMX](https://htmx.org/) (v1.9) is loaded via CDN and allows HTML elements to
make AJAX-style HTTP requests without writing JavaScript. Attributes such as
`hx-post`, `hx-get`, and `hx-target` tell HTMX which requests to fire and where
to swap the response HTML into the page.

This keeps the frontend behaviour close to the HTML markup and avoids the
complexity of a separate JavaScript framework.

### Bootstrap

[Bootstrap 5](https://getbootstrap.com/) (v5.3) is loaded via CDN and provides
the utility classes and components (cards, buttons, modals, navigation bars) used
throughout the UI.

### Layouts

All pages share two layout files:

| File | Purpose |
|---|---|
| `components/layouts/root.html.heex` | Outermost shell — `<html>`, `<head>`, CDN script tags |
| `components/layouts/app.html.heex` | Inner layout — navigation bar, flash messages, `<main>` content area |

The root layout is set by the `:browser` pipeline plug `:put_root_layout`. The
app layout wraps the inner content rendered by each controller/template.

---

## Summary

ZipLiner is a conventional Phoenix MVC application. Requests enter through the
**Endpoint**, pass through **Plug pipelines** that handle sessions, authentication,
and security headers, reach a **Controller** that delegates to **context modules**
for business logic, and are finally rendered by **HEEx templates**. The data layer
uses **Ecto** with SQLite3 and is organised around nine schemas grouped into four
domain contexts. The frontend progressively enhances server-rendered HTML with
**HTMX** for dynamic interactions and **Bootstrap** for styling.
