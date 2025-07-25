FROM ruby:3.2.3-slim

ARG ARG_RAILS_MASTER_KEY

ENV ACCEPT_EULA=Y \
    APP_DIR=/app \
    BUNDLE_PATH=/bundle \
    RAILS_SERVE_STATIC_FILES=true \
    DEBIAN_FRONTEND=noninteractive \
    PORT=3000 \
    RAILS_ENV=production \
    RAILS_MASTER_KEY=${ARG_RAILS_MASTER_KEY}

# Install necessary packages
RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      build-essential \
      libpq-dev \
      curl \
      git && \
    # Node.js & Yarn for asset precompilation
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR $APP_DIR

# Copy only Gemfile for layer caching
COPY Gemfile Gemfile.lock ./

# Install production gems
RUN gem update --system && \
    gem install bundler && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy the rest of the app
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile

EXPOSE $PORT

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
