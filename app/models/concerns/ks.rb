module Ks
  BASE = Pathname.new("#{ENV['HOME']}/.log/kanshi.d")
  SERVERS = %w/hok mor tsu/
  LOGS = %w/boot app mem top/

  def self.table_name_prefix() = "ks_"

  def self.import
    journal = Ks::Journal.new
    begin
      SERVERS.each do |server|
        dir = BASE + server
        raise "directory #{dir} does not exist" unless dir.directory?
        Ks::Boot.import(dir, server, journal)
      end
    rescue => e
      journal.add_error(e.message)
    end
    journal.save!
    journal
  end

  def self.setup_test(n)
    source = Rails.root + "spec/files/kanshi/#{n}"
    target = BASE
    SERVERS.each do |server|
      raise "source directory for #{server} does not exist" unless (source + server).directory?
      raise "target directory for #{server} does not exist" unless (target + server).directory?
      LOGS.each do |log|
        file1 = source + server + "#{log}.log"
        file2 = target + server + "#{log}.log"
        file3 = target + server + "#{log}.tmp"
        if file1.file?
          system("cp #{file1} #{file2}")
        else
          file2.delete if file2.file?
        end
        file3.delete if file3.file?
      end
    end
  end
end
