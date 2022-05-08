namespace :match do
  # bin/cap production 'match:one[manchester-city]'
  desc "Update one teams matches"
  task :one, [:team] => 'deploy:set_rails_env' do |task, args|
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake "match:one[#{args[:team]}]"
        end
      end
    end
  end

  # bin/cap production match:all
  desc "Update all teams matches (cron does this anyway but if you can't wait)"
  task :all => 'deploy:set_rails_env' do |task|
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake "match:all"
        end
      end
    end
  end
end
