# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require_relative '../config/environment'
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

  # For removing active_storage files after a test (database_cleaner takes care of records).
  config.after(:each, type: :active_storage) { remove_active_storage_files }
  config.after(:suite) { remove_active_storage_files }
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

def login(role="admin")
  user = create(:user, role: role)
  visit sign_in_path
  click_link t("session.sign_in")
  fill_in t("email"), with: user.email
  fill_in t("session.password"), with: user.password
  click_button t("session.sign_in")
end

def wait_a_while(delay=0.3)
  sleep(delay)
end

def t(key, *arg)
  I18n.t(key, *arg)
end

def error
  "div.help-block"
end

def expect_error(page, text)
  expect(page).to have_css("div.alert-danger", text: text)
end

def remove_active_storage_files
  FileUtils.rm_rf("#{Rails.root}/tmp/storage")
end
