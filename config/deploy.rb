set :application, "sni_mio_app"

set :repo_url, "git@bitbucket.org:sanichi/sni_mio_app.git"
set :branch, "master"

set :linked_files, %w{config/database.yml config/master.key}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :log_level, :info

# set :format, :pretty
# set :pty, true
# set :keep_releases, 5
