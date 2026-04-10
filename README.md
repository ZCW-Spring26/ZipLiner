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

When creating your GitHub OAuth App, set the callback URL to:

```
http://localhost:4000/auth/github/callback
```

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

