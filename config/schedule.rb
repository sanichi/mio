set :output, "#{path}/log/cron.log"
set :job_template, nil

every :day, at: "4:30 am" do
  command "pg_dump sni_mio_app_production --clean --compress=1 --file ~/bak/db/mio-$(date +%Y-%m-%d).sql.gz"
end

every :day, at: "5:00 am" do
  command "cd #{path}; tar -zcvf ~/bak/images/mio-$(date +%Y-%m-%d).tar.gz `find public/system/pictures -print | grep '/original/'`
end
