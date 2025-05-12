module Ks
  BASE = Pathname.new("#{ENV['HOME']}/.log/kanshi.d")
  SERVERS = %w/hok mor tsu/
  LOGS = %w/boot app mem top cpu/

  class W < StandardError; end
  class E < StandardError; end

  def self.table_name_prefix() = "ks_"

  def self.import
    journal = Ks::Journal.create
    if BASE.directory?
      SERVERS.each do |server|
        LOGS.each do |log|
          digest(journal, server, log)
        end
      end
    else
      journal.add_error("directory #{BASE} does not exist")
    end
    journal.save!
    journal
  end

  def self.digest(journal, server, log)
    file = BASE + server + "#{log}.log"
    path = file.to_s.split("/").last(2).join("/") # for logging
    unless file.file?
      journal.add_neatly(path, "-")
      return
    end
    unless file.size > 0
      journal.add_neatly(path, "0")
      file.delete
      return
    end

    begin
      num = 0
      file.each_line do |line|
        num += 1
        line.chomp!
        begin
          raise W, "line #{num} of #{path} is blank" if line.blank?
          begin
            time = line[0,19].to_datetime
          rescue Date::Error
            raise E, "line #{num} (#{log.match?(/\A(top|cpu)\z/) ? line[0,19] : line}) of #{path} can't be parsed into a datetime"
          end
          case log
          when "app", "boot"
            if log == "boot"
              app = "reboot"
            else
              raise E, "line #{num} (#{line}) of #{path} has no app" unless line.match(/\s([a-z]{2,6})\z/)
              app = $1
            end
            if Ks::Boot.find_by(happened_at: time, server: server, app: app)
              next if app == "reboot"
              raise W, "line #{num} (#{line}) of #{path} is a duplicate"
            end
            journal.boots.create!(happened_at: time, server: server, app: app)
          when "mem"
            raise W, "line #{num} (#{line}) of #{path} is a duplicate" if Ks::Mem.find_by(measured_at: time, server: server)
            raise E, "line #{num} (#{line}) of #{path} has can't be parsed into 6 numbers" unless line.match(/\s(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*\z/)
            journal.mems.create!(measured_at: time, server: server, total: $1, used: $2, free: $3, avail: $4, swap_used: $5, swap_free: $6)
          when "top"
            sample = line.truncate(30) # for logging, if we need to, otherwise top lines can be very long
            raise W, "line #{num} (#{sample}) of #{path} is a duplicate" if Ks::Top.find_by(measured_at: time, server: server)
            raise E, "line #{num} (#{sample}) of #{path} can't be split in parts" unless line.match(/\A[-\d]+\s[:\d]+\s(.+)\z/)
            procs = $1.split("||")
            raise E, "line #{num} (#{sample}) of #{path} doesn't appear to have 10 procs" unless procs.size == 10
            top = journal.tops.create!(measured_at: time, server: server)
            procs.each do |proc|
              raise E, "line #{num} (#{sample}) of #{path} has an unparsable proc (#{proc[0,20]}...)" unless proc.match(/\A([1-9]\d*)\|(\d+)\|(.+)\z/)
              top.procs.create!(pid: $1, mem: $2, command: $3)
              journal.procs_count += 1
            end
          when "cpu"
            sample = line.truncate(30) # for logging, if we need to, otherwise cpu lines can be very long
            raise W, "line #{num} (#{sample}) of #{path} is a duplicate" if Ks::Cpu.find_by(measured_at: time, server: server)
            raise E, "line #{num} (#{sample}) of #{path} can't be split in parts" unless line.match(/\A[-\d]+\s[:\d]+\s(.+)\z/)
            pcpus = $1.split("||")
            raise E, "line #{num} (#{sample}) of #{path} doesn't appear to have any pcpus" unless pcpus.size > 0
            cpu = journal.cpus.create!(measured_at: time, server: server)
            pcpus.each do |pcpu|
              raise E, "line #{num} (#{sample}) of #{path} has an unparsable pcpu (#{pcpu[0,20]}...)" unless pcpu.match(/\A([1-9]\d*)\|(\d+\.\d+)\|(.+)\z/)
              cpu.pcpus.create!(pid: $1, pcpu: $2, command: $3)
              journal.pcpus_count += 1
            end
          end
        rescue W => e
          journal.add_warning(e.message)
        rescue E => e
          journal.add_error(e.message)
        end
      end
      journal.add_neatly(path, num)
    rescue => e
      journal.add_error("ABORT #{path}: #{e.message}")
    ensure
      file.delete
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
        if file1.file?
          system("cp #{file1} #{file2}")
        else
          file2.delete if file2.file?
        end
      end
    end
  end
end
