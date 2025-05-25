namespace :deploy do
  desc "Run automatically during a deploy to add to the kanshi app.log"
  task :log do
    on roles(:app) do |_host|
      execute "kanshi.sh", fetch(:application)
    end
  end
end

after :'deploy:restart', :'deploy:log'

namespace :kanshi do
  namespace :procs do

    # bin/cap production kanshi:procs:create
    desc "Create new shortened proc command versions"
    task :create => 'deploy:set_rails_env' do |task, args|
      on primary(:app) do
        within current_path do
          with :rails_env => fetch(:rails_env) do
            rake "kanshi:procs"
          end
        end
      end
    end

    # bin/cap production kanshi:procs:update
    desc "Create and update shortened proc command versions"
    task :update => 'deploy:set_rails_env' do |task, args|
      on primary(:app) do
        within current_path do
          with :rails_env => fetch(:rails_env) do
            rake "kanshi:procs[a,u]"
          end
        end
      end
    end
  end

  namespace :pcpus do

    # bin/cap production kanshi:pcpus:create
    desc "Create new shortened pcpu command versions"
    task :create => 'deploy:set_rails_env' do |task, args|
      on primary(:app) do
        within current_path do
          with :rails_env => fetch(:rails_env) do
            rake "kanshi:pcpus"
          end
        end
      end
    end

    # bin/cap production kanshi:pcpus:update
    desc "Create and update shortened pcpu command versions"
    task :update => 'deploy:set_rails_env' do |task, args|
      on primary(:app) do
        within current_path do
          with :rails_env => fetch(:rails_env) do
            rake "kanshi:pcpus[a,u]"
          end
        end
      end
    end
  end
end
