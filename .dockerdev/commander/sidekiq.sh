#!/bin/bash
set -e

# Set default environment if not provided
RAILS_ENV=${RAILS_ENV:-development}

echo "[INFO] Checking for installed gems..."
bundle check || (
  echo "[INFO] Installing missing gems..."
  bundle install
)

# Wait until database is ready
echo "[INFO] Waiting for database to be ready..."
until bundle exec rails db:version > /dev/null 2>&1; do
  echo "[WARN] Database is unavailable - retrying in 3 seconds..."
  sleep 3
done
echo "[INFO] Database is ready."

echo "[INFO] Starting Sidekiq with environment: $RAILS_ENV"
bundle exec sidekiq -C config/sidekiq.yml -e "$RAILS_ENV"

exec "$@"
