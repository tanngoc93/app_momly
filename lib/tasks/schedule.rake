namespace :schedule do
  desc 'Update cron jobs from Whenever schedule'
  task :update_crontab do
    sh 'bundle exec whenever --update-crontab'
  end
end
