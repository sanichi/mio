# Load DSL and set up stages.
require 'capistrano/setup'

# Include default deployment tasks.
require 'capistrano/deploy'

# For compatibility with future versions of capistrano (replaces :scm setting in deploy.rb).
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Include tasks from other gems in your Gemfile.
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/passenger'

# For prettier console output.
require 'airbrussh/capistrano'
