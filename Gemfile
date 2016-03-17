source 'https://rubygems.org'

gem 'rails', '4.2.5'

gem 'pg'

# Production gems
group :production do
  gem 'unicorn-worker-killer'
end

# Development gems
group :development do
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'meta_request'
    gem 'quiet_assets'
    gem 'spring'
    # gem 'rack-mini-profiler'
    gem 'capistrano', '~> 2.15'
    gem 'bullet'
    gem 'metric_fu'
    gem 'capistrano-unicorn', :require => false, platforms: :ruby
    gem 'thin'
    gem 'capistrano-sidekiq'
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'shoulda-matchers', '2.8.0'
  gem 'faker'
  gem 'email_spec'
end

group :development, :test do
  gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger'
  gem 'pry-byebug'
  gem 'mysql2'
end

# Assets
gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'compass-rails'
gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem 'uglifier', '>= 1.0.3'
gem 'asset_sync'
gem 'sprockets', '2.11.0'

# Web server
gem 'unicorn', :platforms => :ruby

# AJAX file upload
gem 'remotipart', '~> 1.2'
################
# Fix for upload bug for Carrierwave and Rails 4.1
################
gem 'activesupport-json_encoder'

# Logging/Monitoring
gem 'rollbar'
gem 'newrelic_rpm'

# Background processing
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra', :require => nil

# Misc
gem 'protected_attributes'
gem 'tzinfo-data'
gem 'active_presenter'
gem "auto_strip_attributes", "~> 2.0"

# Pagination
gem 'kaminari'

# RTE
gem "wysiwyg-rails"

# Transaction handler
gem 'activemerchant', '1.43.3'
gem 'offsite_payments'

# Authenication
gem 'devise'
gem 'cancan'

# Friendly URLs
gem 'friendly_id'

# Image uploader
gem 'mini_magick'
gem 'carrierwave'
gem 'fog'
gem 'unf' # Dependency for fog

# Sitemap
gem 'sitemap_generator'

# Background processing
gem 'whenever', '>= 0.8.4', :require => false

# JS Variables
gem 'gon'

# GA
gem 'google-api-client'

# Performance
gem 'fast_blank'
gem 'jquery-turbolinks'
gem 'turbolinks'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Test coverage by Codacy
gem 'codacy-coverage', :require => false

# Colour console
gem 'colorize'