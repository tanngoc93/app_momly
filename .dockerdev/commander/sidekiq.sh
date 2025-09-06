#!/bin/bash
set -e

# Default environment if not provided
RAILS_ENV=${RAILS_ENV:-production}
APP_DIR=${APP_DIR:-/app}

cd "$APP_DIR"
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
  # 🔹 Production: verify only, skip dev/test gems
  echo "[INFO] Verifying bundled gems (ignoring dev/test)..."
  if ! BUNDLE_WITHOUT="development:test" bundle check; then
    echo "[ERROR] Gems are missing in production image! Please rebuild the image."
    exit 1
  fi
fi

# 🔹 Optional: wait for database if enabled
if [ "$WAIT_FOR_DB" = "true" ]; then
  echo "[INFO] Waiting for database to be ready..."
  until bundle exec rails db:version > /dev/null 2>&1; do
    echo "[WARN] Database is unavailable - retrying in 3 seconds..."
    sleep 3
  done
  echo "[INFO] Database is ready."
fi

# 🔹 Start Sidekiq
echo "[INFO] Starting Sidekiq with environment: $RAILS_ENV"
bundle exec sidekiq -C config/sidekiq.yml -e "$RAILS_ENV"
exec "$@"
