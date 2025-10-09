# bin/cap production football:matches
namespace :football do
  desc "Update the latest premier league matches"
  task :matches => 'deploy:set_rails_env' do |task, args|
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake "football:matches"
        end
      end
    end
  end
end
