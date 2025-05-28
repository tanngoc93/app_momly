source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "rails", "~> 7.0.8", ">= 7.0.8.7"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "sprockets-rails"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Security & external services
gem "faraday"
gem "rack-attack"
gem "recaptcha"
gem "google-api-client"

# Authentication
gem "devise"
gem "omniauth"
gem "omniauth-google-oauth2"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "rails-erd"
  gem "letter_opener"
  gem "letter_opener_web"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
