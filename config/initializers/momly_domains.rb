Rails.application.config.momly_domains = ENV.fetch('MOMLY_DOMAINS', 'momly.me,www.momly.me')
  .split(',')
  .map { |d| d.strip.downcase }
  .reject(&:blank?)

