# Agent Guidelines for Ruby on Rails Project

## Commands
- **Test all specs**: `bundle exec rspec`
- **Test single file**: `bundle exec rspec spec/models/classifier_spec.rb`  
- **Test single example**: `bundle exec rspec spec/models/classifier_spec.rb:5`
- **Rails console**: `bin/rails console`
- **Database migrate**: `bin/rails db:migrate`
- **Assets precompile**: `bin/rails assets:precompile`

## Code Style
- **Models**: Use ActiveRecord conventions, include modules for shared behavior
- **Controllers**: Inherit from ApplicationController, use before_actions for auth/setup
- **Naming**: Use snake_case for methods/variables, PascalCase for classes
- **Constants**: Define at class level using ALL_CAPS (e.g., `MAX_NAME = 30`)
- **Validations**: Group related validations, use descriptive error messages
- **Methods**: Use single-line method definitions with `def method = expression` for simple getters
- **String manipulation**: Use safe navigation (`&.`) and built-in methods like `squish!`
- **Error handling**: Use rescue in validation methods, add descriptive error messages
- **Tests**: Use RSpec with describe/context/it blocks, FactoryBot for test data
- **Feature tests**: Mark with `js: true` for JavaScript testing, use Capybara helpers
