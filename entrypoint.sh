#!/bin/sh
set -e

# Run database migrations before starting the application.
# This ensures the schema is always up to date when the container starts,
# including after the first launch against a fresh persistent volume.
echo "Running database migrations..."
/app/bin/zip_liner eval "ZipLiner.Release.migrate()"

echo "Starting ZipLiner..."
exec /app/bin/zip_liner start
