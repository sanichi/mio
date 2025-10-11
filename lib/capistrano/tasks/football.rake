# bin/cap production football:matches
# bin/cap production football:matches\[fd\]
# bin/cap production football:matches\[fwp\]
namespace :football do
  desc "Update the latest premier league matches"
  task :matches, [:api] => 'deploy:set_rails_env' do |task, args|
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          if args[:api]
            rake "football:matches[#{args[:api]}]"
          else
            rake "football:matches"
          end
        end
      end
    end
  end
end
