source 'https://rubygems.org'

gem 'rails', '8.0.1'
gem 'haml-rails', '~> 2.0'
gem 'jquery-rails', '~> 4.3'
gem 'sassc-rails', '~> 2.1'
gem 'bootstrap', '~> 5.0'
gem 'terser', '~> 1.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'cancancan', '~> 3.0'
gem 'redcarpet', '~> 3.5'
gem 'activerecord-session_store', '~> 2.0'
gem 'chronic', '~> 0.10'
gem 'date_validator', '~> 0.9'
gem 'jquery-ui-rails', '< 8'
gem 'httparty', '~> 0.22'
gem 'mojinizer', '~> 0.2'
gem 'oga', '~> 3.0'
gem 'ruby-progressbar', '~> 1.10'
gem 'sprockets-rails', '~> 3.4'
gem 'rotp', '~> 6.2'
gem 'rqrcode', '~> 2.1'
gem 'jbuilder', '~> 2.7'
gem 'meta-tags', '~> 2.12'
gem 'csv', '< 4'

group :development, :test do
  gem 'rspec-rails', '< 8'
  gem 'capybara', '~> 3.28'
  gem 'byebug', platforms: :mri
  gem 'launchy', '< 4'
  gem 'factory_bot_rails', '~> 6.0'
  gem 'faker', '< 4'
  gem 'selenium-webdriver', '~> 4.0'
end

# Temporary fix to silence warnings about gem no longer being standard library
gem "ostruct", "~> 0.6.1"

# Temporary fix because of glibc version on Alma Linux 8
gem "nokogiri", force_ruby_platform: true

group :test do
  gem 'database_cleaner-active_record', '~> 2.0'
end

group :development do
  gem 'puma', '< 7'
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-passenger', '~> 0.2', require: false
  gem 'listen', '~> 3.2'
  gem 'awesome_print', '~> 1.9', require: false
end
