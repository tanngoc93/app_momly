# Builder stage: install build tools, gems, and precompile assets
FROM ruby:3.4.5-slim AS builder

ARG ARG_RAILS_MASTER_KEY
ENV APP_DIR=/app \
    BUNDLE_PATH=/bundle \
    DEBIAN_FRONTEND=noninteractive \
    RAILS_ENV=production \
    RAILS_MASTER_KEY=${ARG_RAILS_MASTER_KEY}

RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
        build-essential \
        curl \
        ca-certificates \
        git \
        gnupg \
        libpq-dev \
        libyaml-dev \
        postgresql-client \
        shared-mime-info && \
    # Add Node.js 20 repo manually (slim images don't support add-apt-repository)
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && \
    apt-get install -yq --no-install-recommends nodejs && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR $APP_DIR
COPY Gemfile Gemfile.lock ./

ENV LANG=C.UTF-8 \
    BUNDLE_APP_CONFIG=.bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

RUN gem update --system && \
    gem install bundler && \
    bundle config set --local without 'development test' && \
    bundle install

COPY . .

RUN yarn install --frozen-lockfile && \
    RAILS_ENV=production bundle exec rails assets:clobber && \
    RAILS_ENV=production bundle exec rails assets:precompile && \
    rm -rf node_modules tmp/*

# Runtime stage: lightweight final image with only runtime dependencies
FROM ruby:3.4.5-slim

ENV LANG=C.UTF-8 \
    PORT=3000 \
    APP_DIR=/app \
    BUNDLE_PATH=/bundle \
    BUNDLE_APP_CONFIG=.bundle \
    BUNDLE_WITHOUT=development:test \
    RAILS_SERVE_STATIC_FILES=true \
    DEBIAN_FRONTEND=noninteractive \
    RAILS_ENV=production

RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
        curl \
        procps \
        ca-certificates \
        imagemagick \
        libpq5 \
        libyaml-0-2 \
        libvips42 \
        postgresql-client \
        fonts-dejavu-core fonts-dejavu-extra && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR $APP_DIR

# Copy gems and prebuilt app from builder
COPY --from=builder /bundle /bundle
COPY --from=builder $APP_DIR $APP_DIR

EXPOSE $PORT
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
