#!/bin/bash
set -e

# Default ENV values
RAILS_ENV=${RAILS_ENV:-production}
APP_DIR=${APP_DIR:-/app}

cd "$APP_DIR"

# Let Bundler know the Gemfile
export BUNDLE_GEMFILE="$APP_DIR/Gemfile"

echo "[INFO] Rails environment: $RAILS_ENV"

# 🔹 Dev/Test: allow installing gems if missing
if [ "$RAILS_ENV" = "development" ] || [ "$RAILS_ENV" = "test" ]; then
  echo "[INFO] Checking for installed gems..."
  bundle check || (
    echo "[INFO] Installing missing gems..."
    bundle install
  )
else
  # 🔹 Prod: verify only, skip dev/test gems
  echo "[INFO] Verifying bundled gems (ignoring dev/test)..."
  if ! BUNDLE_WITHOUT="development:test" bundle check; then
    echo "[ERROR] Gems are missing in production image! Please rebuild the image."
    exit 1
  fi
fi

# Ensure tmp/pids exists
mkdir -p "$APP_DIR/tmp/pids"

# Remove any old server.pid
if [ -f "$APP_DIR/tmp/pids/server.pid" ]; then
  echo "[INFO] Removing existing server.pid..."
  rm -f "$APP_DIR/tmp/pids/server.pid"
fi

# 🔹 Optional DB setup (only if RUN_DB_SETUP=true)
if [ "$RUN_DB_SETUP" = "true" ]; then
  echo "[INFO] Running database setup (create, migrate, seed)..."
  bundle exec rails db:create db:migrate db:seed
fi

# 🔹 Export ERD only in dev
if [ "$RAILS_ENV" = "development" ]; then
  echo "[INFO] Exporting ERD (Entity-Relationship Diagram)..."
  bundle exec erd || echo "[WARN] ERD generation failed (optional)"
fi

# 🔹 Start server (can be overridden by CMD args)
if [ "$#" -eq 0 ]; then
  echo "[INFO] Starting Puma server..."
  bundle exec puma -C config/puma.rb
  exec "$@"
else
  echo "[INFO] Running custom command: $*"
  exec "$@"
fi
