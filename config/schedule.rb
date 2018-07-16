set :output, "#{path}/log/cron.log"
set :job_template, nil

every :sunday, at: "4:30 am" do
  command "pg_dump sni_mio_app_production --no-owner --no-privileges --compress=1 --clean --file ~/bak/db/mio-$(date +%Y-%m-%d).sql.gz"
end
