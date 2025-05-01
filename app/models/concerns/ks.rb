module Ks
  SERVERS = %w/hok mor tsu/
  APPS = %w/api bid chess hou mio reboot rek sj smd sta step tmp wd/

  def self.table_name_prefix() = "ks_"

  def self.import(base = Pathname.new("/home/sanichi/.log/kanshi.d"))
    journal = Ks::Journal.new
    begin
      SERVERS.each do |server|
        dir = base + server
        raise "directory #{dir} does not exist" unless dir.directory?
        Ks::Boot.import(dir, server, journal)
      end
    rescue => e
      journal.add_error(e.message)
    end
    journal.save!
    journal
  end
end
