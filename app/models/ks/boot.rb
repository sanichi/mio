module Ks
  class Boot < ActiveRecord::Base
    include Pageable
  
    validates :server, inclusion: { in: SERVERS }
    validates :app, inclusion: { in: APPS }
    validates :happened_at, presence: true, uniqueness: { scope: [:server, :app], message: "the same time with the same server and app" }
  
    scope :descending, -> { order(happened_at: :desc, server: :desc, app: :desc) }
    scope :ascending,  -> { order(happened_at: :asc,  server: :desc, app: :desc) }

    def self.import(dir, server, journal)
      import_rbt(dir, server, journal)
      import_app(dir, server, journal)
    end

    def self.import_rbt(dir, server, journal)
      file = dir + "boot.log"
      return unless file.file?
      return unless file.size > 0

      num = 0
      path = file.to_s.sub!(dir.dirname.to_s, "")
      file.each_line do |line|
        line.chomp!
        num += 1
        if line.blank?
          journal.add_warning("line #{num} of #{path} is blank")
          next
        end
        begin
          Ks::Boot.create!(happened_at: line.to_datetime, server: server, app: "reboot")
        rescue Date::Error
          raise "line #{num} (#{line}) of #{path} can't be parsed into a date"
        end
      end

      tmp = dir + "boot.tmp"
      system("mv #{file} #{tmp}")
    end

    def self.import_app(dir, server, journal)
      file = dir + "app.log"
      return unless file.file?
      return unless file.size > 0

      num = 0
      path = file.to_s.sub!(dir.dirname.to_s, "")
      file.each_line do |line|
        line.chomp!
        num += 1
        if line.blank?
          journal.add_warning("line #{num} of #{path} is blank")
          next
        end
        raise "line #{num} (#{line}) of #{path} has no app" unless line.match(/\s([a-z]{2,6})\z/)
        app = $1
        begin
          Ks::Boot.create!(happened_at: line.to_datetime, server: server, app: app)
        rescue Date::Error
          raise "line #{num} (#{line}) of #{path} can't be parsed into a date"
        end
      end

      tmp = dir + "app.tmp"
      system("mv #{file} #{tmp}")
    end
  
    def self.search(params, path, opt={})
      matches = params[:order] == "asc" ? ascending : descending
      matches = matches.where(server: params[:server]) if SERVERS.include?(params[:server])
      matches = matches.where(app: params[:app]) if APPS.include?(params[:app])
      paginate(matches, params, path, opt)
    end
  end
end
