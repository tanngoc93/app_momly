# config/initializers/sidekiq.rb

require 'sidekiq'
require 'sidekiq/web'

# Define your Redis URL and namespace. The namespace helps
# isolate Sidekiq jobs if multiple applications share the
# same Redis server.
REDIS_URL = ENV.fetch('REDIS_URL', 'redis://localhost:6379')
REDIS_NAMESPACE = ENV.fetch('REDIS_NAMESPACE', 'momly_sidekiq')

Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_URL, namespace: REDIS_NAMESPACE }

  # Create a logger writing to 'sidekiq.log' with rolling settings
  sidekiq_logger = ActiveSupport::Logger.new(
    Rails.root.join('log', 'sidekiq.log'),
    1,              # number of log files to keep (rolling)
    50.megabytes    # max size of each log file
  )

  # Optional: set the log level (DEBUG, INFO, WARN, ERROR, FATAL)
  sidekiq_logger.level = Logger::INFO

  # Optional: use TaggedLogging for formatting logs similar to Rails
  sidekiq_logger = ActiveSupport::TaggedLogging.new(sidekiq_logger)

  # Assign this logger to Sidekiq
  config.logger = sidekiq_logger
end

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_URL, namespace: REDIS_NAMESPACE }
end
