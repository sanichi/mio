module Ks
  SERVERS = %w/hok mor tsu/
  APPS = %w/api bid chess hou mio reboot rek sj smd sta step tmp wd/

  def self.table_name_prefix() = "ks_"
end
