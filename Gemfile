source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '4.0.0.rc1'

gem 'active_model_serializers', github: 'rails-api/active_model_serializers'
gem 'aws-ses', require: 'aws/ses'
gem 'bootstrap-will_paginate'
gem 'cancan'
gem 'carrierwave'
gem 'clearance', '1.0.0.rc7', github: 'adamjacobbecker/clearance'

# order is necessary
gem 'simple_form', '3.0.0.rc'
gem 'client_side_validations', github: 'adamjacobbecker/client_side_validations', branch: '4-0-beta'
gem 'client_side_validations-simple_form', github: 'adamjacobbecker/client_side_validations-simple_form'

gem 'coffee-rails', '~> 4.0.0'
gem 'colorist'
gem 'dalli'
gem 'delayed_job_active_record', '~> 4.0.0.beta2'

# Temporarily in non-development group for seeding test data on deployed instances.
gem 'factory_girl_rails'
gem 'ffaker'

gem 'fog', '~> 1.3.1'
gem 'foreigner', '1.4.0'
gem 'friendly_id', github: 'FriendlyId/friendly_id', branch: 'rails4'
gem 'haml'
gem 'httparty'
gem 'impressionist'
gem 'i18n-js'
gem 'pg'
gem 'pg_search'
gem 'protected_attributes' # for legacy gem support
gem 'rails_admin', github: 'adamjacobbecker/rails_admin', branch: 'rails-4'
gem 'rmagick', '2.13.2'
gem 'sanitize'
gem 'thin'
gem 'twitter_oauth'
gem 'will_paginate', '~> 3.0'

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard-rspec'
  gem 'immigrant'
  gem 'launchy'
  gem 'letter_opener'
  gem 'spring'
  gem 'terminal-notifier-guard'
end

group :development, :test do
  gem 'capybara', '2.0.3'
  gem 'capybara-webkit'
  gem 'database_cleaner', '~> 1.0.0.RC1'
  gem 'fuubar'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'simplecov', require: false
end

# Assets
gem 'execjs'
gem 'font-awesome-sass-rails'
gem 'haml_coffee_assets'
gem 'sass-rails', '~> 4.0.0.rc1'
gem 'select2-rails'
gem 'uglifier', '>= 1.0.3'

# Heroku
group :heroku do
  gem 'rails_log_stdout', github: 'heroku/rails_log_stdout'
  gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'
end
