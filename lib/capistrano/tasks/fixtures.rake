namespace :rapid do
  # bin/cap production 'rapid:fixtures
  desc "Update one teams matches"
  task :fixtures => 'deploy:set_rails_env' do |task, args|
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake "rapid:fixtures[p]"
        end
      end
    end
  end
end
