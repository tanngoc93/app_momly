#!/bin/bash
set -e

# Ensure RAILS_ENV is set (fallback to development)
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

# Export ERD file (only in development)
if [ "$RAILS_ENV" = "development" ]; then
  echo "[INFO] Exporting ERD (Entity-Relationship Diagram)..."
  bundle exec erd || echo "[WARN] ERD generation failed (optional)"
fi

# Create tmp/pids if not exists
if [ ! -d "$APP_DIR/tmp/pids" ]; then
  echo "[INFO] Creating tmp/pids directory..."
  mkdir -p "$APP_DIR/tmp/pids"
fi

# Remove a potentially pre-existing server.pid for Rails
if [ -f "$APP_DIR/tmp/pids/server.pid" ]; then
  echo "[INFO] Removing existing server.pid file..."
  rm -f "$APP_DIR/tmp/pids/server.pid"
fi

# Run DB setup and start server
echo "[INFO] Running database setup (create, migrate, seed)..."
bundle exec rails db:create db:migrate seed:migrate

echo "[INFO] Starting Puma server..."
bundle exec puma -C config/puma.rb

exec "$@"
