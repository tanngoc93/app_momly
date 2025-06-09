# Use this file to easily define all of your cron jobs.

env :PATH, ENV['PATH']
set :output, 'log/cron.log'

# Remove expired guest links once per day
every 1.day, at: '2:00 am' do
  runner 'CleanupExpiredGuestLinksJob.perform_later'
end
