# Load DSL and set up stages.
require 'capistrano/setup'

# Include default deployment tasks.
require 'capistrano/deploy'

# Include tasks from other gems in your Gemfile.
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/console'
require 'capistrano/rails/migrations'
require 'capistrano/passenger'
require 'whenever/capistrano'

# Load custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
