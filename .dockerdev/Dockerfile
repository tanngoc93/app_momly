FROM ruby:3.2.3-slim

ARG ARG_RAILS_MASTER_KEY

ENV PORT=3000 \
    RAILS_MASTER_KEY=$ARG_RAILS_MASTER_KEY \
    RAILS_ENV=production \
    BUNDLE_PATH=/bundle \
    APP_DIR=/app \
    RAILS_SERVE_STATIC_FILES=true \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      build-essential \
      libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR $APP_DIR

COPY Gemfile Gemfile.lock ./

ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_APP_CONFIG=.bundle

RUN gem update --system && \
    gem install bundler && \
    bundle config set --local without 'development test' && \
    bundle install

COPY . ./

RUN RAILS_ENV=production bundle exec rails assets:precompile

EXPOSE $PORT

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
