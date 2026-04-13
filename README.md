# ZipLiner

The private professional network for ZipCode Wilmington students & alumni.

## Stack

| Layer | Technology |
|-------|------------|
| Backend | Elixir / Phoenix 1.7 |
| Frontend | HTMX 1.9 + Tailwind CSS |
| Database | SQLite3 (via `ecto_sqlite3`) |
| Auth | GitHub OAuth2 (required) + LinkedIn URL (optional) |
| Real-time | Phoenix PubSub / WebSockets |

## Quick Start

### Prerequisites

- Elixir >= 1.14
- Erlang/OTP >= 25
- Node.js >= 18 (for asset building)
- A [GitHub OAuth App](https://github.com/settings/developers) (for authentication)

### Setup

```bash
# Install dependencies
mix setup

# Set your GitHub OAuth credentials (dev only — also accepts env vars)
# Edit config/dev.exs or export:
export GITHUB_CLIENT_ID=your_client_id
export GITHUB_CLIENT_SECRET=your_client_secret

# Start the server
mix phx.server
```

Visit [`http://localhost:4000`](http://localhost:4000).

### GitHub OAuth App Configuration

When creating your GitHub OAuth App at <https://github.com/settings/developers>:

| Field | Value |
|---|---|
| **Application name** | `ZipLiner` |
| **Homepage URL** | `http://localhost:4000` |
| **Authorization callback URL** | `http://localhost:4000/auth/github/callback` |

> **Important:** The **Application name** is what GitHub displays to users on the
> authorization page ("Authorize ZipLiner to access your account"). Make sure it is
> set to `ZipLiner` — not your personal GitHub username or any other value.

## Project Structure

```
lib/
├── zip_liner/
│   ├── accounts/        # Member & Cohort schemas + context
│   ├── social/          # Connections, Posts, Channels, Reactions, Replies, DMs
│   ├── projects/        # Project Showcase
│   ├── notifications/   # In-app notifications
│   ├── application.ex
│   ├── mailer.ex
│   └── repo.ex
└── zip_liner_web/
    ├── admin/           # Admin controllers (Cohorts, Members)
    ├── components/      # Layouts, CoreComponents
    ├── controllers/     # Page, Auth, Feed, Member, Post, Project, etc.
    ├── plugs/           # LoadCurrentMember, RequireAuth
    ├── endpoint.ex
    ├── gettext.ex
    ├── router.ex
    └── telemetry.ex
```

## Data Model

| Entity | Key Fields |
|--------|-----------|
| Member | github_id, github_username, display_name, cohort_id, role, status |
| Cohort | name, start_date, graduation_date |
| Connection | member_id_a, member_id_b, status (pending/accepted) |
| Post | type, content, author_id, channel_id |
| Reaction | kind (thumbs_up/fire/lightbulb/celebrate), post_id, member_id |
| Reply | content, post_id, author_id |
| Project | name, description, repo_url, demo_url, status, tech_stack |
| Channel | name, type (cohort/topic/staff/dm) |
| DirectMessage | content, sender_id, recipient_id |
| Notification | type, payload, recipient_id, read_at |

## Running Tests

```bash
mix test
```

## Docker

### Quick start with Docker Compose

```bash
# Copy the example env file and fill in your credentials
cp .env.example .env
# Edit .env with your values, then:
docker compose up --build
```

The SQLite database is stored in a named Docker volume (`zipliner_data`) and is
automatically preserved across container restarts and re-builds.

Database migrations run automatically every time the container starts.

### Required environment variables

| Variable | Description |
|---|---|
| `SECRET_KEY_BASE` | 64-byte secret — generate with `mix phx.gen.secret` |
| `GITHUB_CLIENT_ID` | GitHub OAuth App client ID |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth App client secret |
| `PHX_HOST` | Public hostname (default: `localhost`) |
| `PORT` | Port to expose on the host (default: `4000`) |

### Building the image manually

```bash
docker build -t zipliner .
docker run -d \
  -p 4000:4000 \
  -v zipliner_data:/data \
  -e SECRET_KEY_BASE=<secret> \
  -e GITHUB_CLIENT_ID=<id> \
  -e GITHUB_CLIENT_SECRET=<secret> \
  -e PHX_HOST=<hostname> \
  zipliner
```

## Production Deployment

```bash
# Build assets
mix assets.deploy

# Set required environment variables:
export SECRET_KEY_BASE=$(mix phx.gen.secret)
export GITHUB_CLIENT_ID=...
export GITHUB_CLIENT_SECRET=...
export DATABASE_PATH=/path/to/zipliner_prod.db
export PHX_HOST=yourdomain.com
export PORT=4000

MIX_ENV=prod mix ecto.migrate
MIX_ENV=prod mix phx.server
```

