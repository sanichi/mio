namespace :match do
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
end
