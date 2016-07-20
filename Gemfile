source "https://rubygems.org"

gem "rails", "5.0.0"
gem "pg"
gem "haml-rails"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "therubyracer", platforms: :ruby
gem "cancancan", "~> 1.10"
gem "redcarpet", "~> 3.2"
gem "whenever", require: false
gem "paperclip", "~> 5.0.0"
gem "rack-mini-profiler", require: false
gem "chronic", "~> 0.10"
gem "libv8", "3.16.14.11" # not .14 because we have to wait for patch for clang 7.3.0 on macos

group :development do
  gem "capistrano-rails"
  gem "capistrano-rails-console"
  gem "capistrano-passenger"
  gem "airbrussh", :require => false
  gem "wirble"
  gem "awesome_print", require: "ap"
end

group :development, :test do
  gem "rspec-rails", "~> 3.0"
  gem "capybara"
  gem "selenium-webdriver"
  gem "factory_girl_rails", "~> 4.0"
  gem "launchy"
  gem "faker"
  gem "database_cleaner"
  gem "byebug"
end
