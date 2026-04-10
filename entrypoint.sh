#!/bin/sh
set -e

# Run database migrations before starting the application.
# This ensures the schema is always up to date when the container starts,
# including after the first launch against a fresh persistent volume.
echo "Running database migrations..."
if ! /app/bin/zip_liner eval "ZipLiner.Release.migrate()"; then
  echo "ERROR: Database migrations failed. Aborting startup." >&2
  exit 1
fi

echo "Starting ZipLiner..."
exec /app/bin/zip_liner start
