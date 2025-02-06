# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

Capybara.configure do |config|
  config.exact = true # exact matches
end

# Temporary solution to selenium deprecation messages.
Selenium::WebDriver.logger.ignore(:clear_local_storage, :clear_session_storage)

def login(role="admin")
  user = create(:user, role: role)
  visit sign_in_path
  click_link t("session.sign_in")
  fill_in t("email"), with: user.email
  fill_in t("session.password"), with: user.password
  click_button t("session.sign_in")
  user
end

def logout(user)
  click_link t("session.sign_out", user: user.initials)
end

def otp_attempt
  ROTP::TOTP.new(User::OTP_TEST_SECRET, issuer: User::OTP_ISSUER).now
end

def t(key, **opts)
  I18n.t(key, **opts)
end

def expect_error(page, text)
  expect(page).to have_css("div.alert-danger", text: text)
end

def expect_notice(page, text)
  expect(page).to have_css("div.alert-success", text: text)
end

def test_file_path(name)
  path = Rails.root + "spec" + "files" + name
  raise "non-existant sample file (#{name})" unless File.exist?(path)
  path
end

def wait_a_while(delay=0.3)
  sleep(delay)
end
