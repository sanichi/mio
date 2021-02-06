namespace :match do
  desc "Update one teams matches"
  task :live, [:command] => 'deploy:set_rails_env' do |task, args|
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute "echo", '$RAILS_ENV'
        end
      end
    end
  end
end
