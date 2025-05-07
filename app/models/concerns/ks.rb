module Ks
  BASE = Pathname.new("#{ENV['HOME']}/.log/kanshi.d")
  SERVERS = %w/hok mor tsu/
  LOGS = %w/boot app mem top/

  def self.table_name_prefix() = "ks_"

  def self.import
    journal = Ks::Journal.create
    begin
      SERVERS.each do |server|
        dir = BASE + server
        raise "directory #{dir} does not exist" unless dir.directory?
        _import(dir, server, journal, "boot")
        _import(dir, server, journal, "app")
        _import(dir, server, journal, "mem")
        _import(dir, server, journal, "top")
      end
    rescue => e
      journal.add_error(e.message)
    end
    journal.save!
    journal
  end

  def self._import(dir, server, journal, name)
    begin
      file = dir + "#{name}.log"
      path = file.to_s.split("/").last(2).join("/")
      unless file.file?
        journal.add_neatly(path, "-")
        return
      end
      unless file.size > 0
        journal.add_neatly(path, "0")
        return
      end

      num = 0
      file.each_line do |line|
        line.chomp!
        num += 1
        if line.blank?
          journal.add_warning("line #{num} of #{path} is blank")
          next
        end
        begin
          time = line[0,19].to_datetime
        rescue Date::Error
          raise "line #{num} (#{name == "top" ? line[0,19] : line}) of #{path} can't be parsed into a datetime"
        end
        case name
        when "app", "boot"
          if name == "boot"
            app = "reboot"
          else
            raise "line #{num} (#{line}) of #{path} has no app" unless line.match(/\s([a-z]{2,6})\z/)
            app = $1
          end
          if Ks::Boot.find_by(happened_at: time, server: server, app: app)
            journal.add_warning("line #{num} (#{line}) of #{path} is a duplicate") unless app == "reboot"
            next
          end
          journal.boots.create!(happened_at: time, server: server, app: app)
        when "mem"
          if Ks::Mem.find_by(measured_at: time, server: server)
            journal.add_warning("line #{num} (#{line}) of #{path} is a duplicate")
            next
          end
          raise "line #{num} (#{line}) of #{path} has can't be parsed into 6 numbers" unless line.match(/\s(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*\z/)
          journal.mems.create!(measured_at: time, server: server, total: $1, used: $2, free: $3, avail: $4, swap_used: $5, swap_free: $6)
        when "top"
          sample = line.truncate(30) # for logging, if we need to, otherwise top lines can be very long
          if Ks::Top.find_by(measured_at: time, server: server)
            journal.add_warning("line #{num} (#{sample}) of #{path} is a duplicate")
            next
          end
          raise "line #{num} (#{sample}) of #{path} can't be split in parts" unless line.match(/\A[-\d]+\s[:\d]+\s(.+)\z/)
          procs = $1.split("||")
          raise "line #{num} (#{sample}) of #{path} doesn't appear to have 10 procs" unless procs.size == 10
          top = journal.tops.create!(measured_at: time, server: server)
          procs.each do |proc|
            raise "line #{num} (#{sample}) of #{path} has an unparsable proc (#{proc[0,20]}...)" unless proc.match(/\A([1-9]\d*)\|(\d+)\|(.+)\z/)
            top.procs.create!(pid: $1, mem: $2, command: $3)
          end
          journal.procs_count += top.procs_count
        end
      end
      journal.add_neatly(path, num)

      tmp = dir + "#{name}.tmp"
      system("mv #{file} #{tmp}")
    rescue => e
      journal.add_error(e.message)
    end
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
