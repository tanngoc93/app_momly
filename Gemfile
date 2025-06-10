# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.3"

# ----------------------------------------
# Core Framework & Runtime
# ----------------------------------------
gem "rails",                   "~> 7.0.8", ">= 7.0.8.7"
gem "pg",                      "~> 1.1"                  # PostgreSQL
gem "puma",                    "~> 5.0"                  # Web server
gem "sprockets-rails"                                     # Asset pipeline
gem "importmap-rails"                                    # ESM for JS
gem "turbo-rails"                                        # Hotwire: Turbo
gem "stimulus-rails"                                     # Hotwire: Stimulus
gem "jbuilder"                                           # JSON APIs
gem "bootsnap",                require: false

# ----------------------------------------
# Authentication
# ----------------------------------------
gem "activeadmin"                                         # Admin panel
gem "devise"                                              # User auth
gem "omniauth"                                            # OAuth base
gem "omniauth-google-oauth2"                              # Google OAuth
gem "omniauth-rails_csrf_protection"

# ----------------------------------------
# Utilities & Helpers
# ----------------------------------------
gem "seed_migration"                                      # Data migrations
gem "pagy",                    "~> 9.3"                    # Pagination

# ----------------------------------------
# External APIs & Security
# ----------------------------------------
gem "faraday"                                             # HTTP client
gem "nokogiri"                                           # HTML parsing
gem "rack-attack"                                         # Rate limiter
gem "google-api-client"                                   # Google API SDK
gem "recaptcha"                                           # Google reCAPTCHA

# ----------------------------------------
# Background Jobs (optional)
# ----------------------------------------
gem "sidekiq"

# ----------------------------------------
# File uploads / Cloud (optional)
# ----------------------------------------
# gem "carrierwave",             "~> 3.0"

# ----------------------------------------
# UI, Styling, JS Helpers (optional)
# ----------------------------------------
# gem "jquery-rails"

# ----------------------------------------
# Dev & Test Tools
# ----------------------------------------
group :development, :test do
  gem "debug",                 platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "rails-erd"                                         # Diagram
  gem "letter_opener"                                     # Open emails in browser
  gem "letter_opener_web"                                 # Web UI for above
  gem "web-console"                                       # Rails console in browser
  gem "whenever", "~> 0.9.4"
end

group :test do
  gem "capybara"                                          # Feature tests
  gem "selenium-webdriver"                                # Browser driver
end

# ----------------------------------------
# Platform-specific
# ----------------------------------------
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
