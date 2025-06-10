#!/bin/bash
set -e

# Set default environment if not provided
RAILS_ENV=${RAILS_ENV:-development}

echo "[INFO] Checking for installed gems..."
bundle check || (
  echo "[INFO] Installing missing gems..."
  bundle install
)

# Wait until PostgreSQL is ready (not Rails)
# echo "[INFO] Waiting for PostgreSQL to be ready..."
# until pg_isready -h "$DATABASE_HOST" -p "$DATABASE_PORT" -U "$DATABASE_USER" > /dev/null 2>&1; do
#   echo "[WARN] PostgreSQL not ready - retrying in 3 seconds..."
#   sleep 3
# done
# echo "[INFO] PostgreSQL is ready."

echo "[INFO] Starting Sidekiq with environment: $RAILS_ENV"
# Explicitly require the Rails environment to ensure all
# constants and autoload paths are loaded correctly.
bundle exec sidekiq -C config/sidekiq.yml -e "$RAILS_ENV" -r ./config/environment

exec "$@"
