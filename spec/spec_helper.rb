require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/retry'
require 'capybara/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.order = "random"
  config.global_fixtures = :all
  config.verbose_retry = true
  config.default_retry_count = 2
end

Capybara.javascript_driver = :webkit
Capybara.default_wait_time = 10
Delayed::Worker.delay_jobs = false
