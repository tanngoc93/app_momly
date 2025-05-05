FROM ruby:3.1.2-slim

ARG ARG_RAILS_MASTER_KEY

ENV PORT=3000 \
    RAILS_MASTER_KEY=$ARG_RAILS_MASTER_KEY \
    RAILS_ENV=production \
    BUNDLE_PATH=/bundle \
    APP_DIR=/app \
    DEBIAN_FRONTEND=noninteractive \
    ACCEPT_EULA=Y \
    TTF_MSCORE_INSTALLER_LICENSE_ACCEPTED=1

RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends software-properties-common && \
    apt-add-repository contrib && \
    apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      gnupg2 \
      curl \
      less \
      git \
      build-essential \
      python3 \
      python3-pip \
      libpq-dev \
      postgresql-client \
      shared-mime-info \
      libvips42 \
      imagemagick \
      ffmpeg \
      graphviz \
      ttf-mscorefonts-installer && \
    apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

RUN pip3 install --no-cache-dir requests pillow moviepy
RUN mkdir -p $APP_DIR $APP_DIR/log $APP_DIR/tmp/pids $APP_DIR/tmp/files

# Cài đặt NodeJS từ Nodesource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY Gemfile      $APP_DIR/Gemfile
COPY Gemfile.lock $APP_DIR/Gemfile.lock

WORKDIR $APP_DIR

# Application dependencies
# External Aptfile for that
COPY ./.dockerdev/Aptfile /tmp/Aptfile
RUN apt-get update -qq && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
      $(grep -Ev '^\s*#' /tmp/Aptfile | xargs) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

# Store Bundler settings in the project's root
ENV BUNDLE_APP_CONFIG=.bundle

# Upgrade RubyGems and install latest Bundler
RUN gem update --system && \
    gem install bundler && \
    bundle config set --local without 'development test' && bundle install

COPY . $APP_DIR/

RUN yarn install --frozen-lockfile --production=false
RUN RAILS_ENV=production bundle exec rake vite:clobber
RUN RAILS_ENV=production bundle exec rake vite:build && \
    rm -rf tmp/*

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE $PORT
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
