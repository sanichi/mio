namespace :wk do
  # bin/cap production 'wk:tweak'
  desc "Tweak WK (so far: just add more similar kanjis) - see models/wk/tweak.rb"
  task :tweak => 'deploy:set_rails_env' do |task, args|
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute :rails, :r, "Wk::Tweak.update"
        end
      end
    end
  end
end
