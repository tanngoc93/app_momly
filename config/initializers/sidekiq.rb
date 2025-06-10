# config/initializers/sidekiq.rb

require 'sidekiq'
require 'sidekiq/web'

# Define your Redis URL
REDIS_URL = ENV.fetch('REDIS_URL', 'redis://localhost:6379')

Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_URL }

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
  config.redis = { url: REDIS_URL }
end
