source "https://rubygems.org"

gem "rails", "~> 6.0.3.2"
gem "pg", '>= 0.18', '< 2.0'
gem "haml-rails", '~> 2.0'
gem "sassc-rails", '~> 2.1'
gem "uglifier", '~> 4.2'
gem "jquery-rails", '~> 4.3'
gem "jquery-ui-rails", '~> 6.0'
gem "bootstrap", '~> 4.3'
gem "cancancan", "~> 3.0"
gem "redcarpet", "~> 3.5"
gem "chronic", "~> 0.10"
gem "oga", "~> 3.0"
gem "mechanize", "~> 2.7"
gem "ruby-progressbar", "~> 1.10"
gem "date_validator", "~> 0.9"
gem "mini_magick", "~> 4.9"
gem "mojinizer", "~> 0.2"
gem "activerecord-session_store"

group :development do
  gem "puma", "~> 4.1"
  gem "capistrano-rails", '~> 1.4', require: false
  gem "capistrano-passenger", '~> 0.2', require: false
  gem "awesome_print", '~> 1.8', require: "ap"
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring', '~> 2.1'
  gem 'spring-watcher-listen', '~> 2.0'
end

group :test do
  gem 'database_cleaner-active_record', '~> 1.8'
end

group :development, :test do
  gem "rspec-rails", "~> 4.0"
  gem "capybara", "~> 3.8"
  gem "selenium-webdriver"
  gem "factory_bot_rails", "~> 5.0"
  gem "launchy", "~> 2.4"
  gem "faker", "~> 2.1"
  gem "byebug", platform: :mri
end
