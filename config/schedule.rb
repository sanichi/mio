set :output, "log/cron.log"
set :job_template, nil

every :day, at: "4:30 am" do
  command "pg_dump sni_mio_app_production --clean --file ~/bak/db/mio-$(date +%Y-%m-%d).sql"
end
