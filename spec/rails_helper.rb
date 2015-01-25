# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Require supporting ruby files (e.g. custom matchers, additional configuration).
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # See spec/support/database_cleaner.rb.
  config.use_transactional_fixtures = false

  # See https://relishapp.com/rspec/rspec-rails/docs.
  config.infer_spec_type_from_file_location!
end

Capybara.configure do |config|
  # Exact matches.
  config.exact = true
end

# Where are the test files?
def test_file_path(name)
  path = Rails.root + "spec" + "files" + name
  raise "non-existant sample file (#{name})" unless File.exists?(path)
  path
end

def login
  visit sign_in_path
  click_link sign_in
  fill_in password, with: test_password
  click_button sign_in
end
