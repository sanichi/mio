module Ks
  class Boot < ActiveRecord::Base
    include Pageable

    APPS = %w/reboot api bid chess hou mio rek sj smd sta step tmp wd/
  
    validates :server, inclusion: { in: SERVERS }
    validates :app, inclusion: { in: APPS }
    validates :happened_at, presence: true, uniqueness: { scope: [:server, :app], message: "the same time with the same server and app" }
  
    scope :descending, -> { order(happened_at: :desc, server: :desc, app: :desc) }
    scope :ascending,  -> { order(happened_at: :asc,  server: :desc, app: :desc) }

    def self.import(dir, server, journal)
      _import(dir, server, journal, "boot")
      _import(dir, server, journal, "app")
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
            time = line.to_datetime
          rescue Date::Error
            raise "line #{num} (#{line}) of #{path} can't be parsed into a date"
          end
          app = "reboot"
          if name == "app"
            raise "line #{num} (#{line}) of #{path} has no app" unless line.match(/\s([a-z]{2,6})\z/)
            app = $1
          end
          if Ks::Boot.find_by(happened_at: time, server: server, app: app)
            journal.add_warning("line #{num} (#{line}) of #{path} is a duplicate")
            next
          end
          Ks::Boot.create!(happened_at: time, server: server, app: app)
          journal.boot += 1
        end
        journal.add_neatly(path, num)

        tmp = dir + "#{name}.tmp"
        system("mv #{file} #{tmp}")
      rescue => e
        journal.add_error(e.message)
      end
    end

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "happened"
          ascending
        else
          descending
        end
      matches = matches.where(server: params[:server]) if SERVERS.include?(params[:server])
      matches = matches.where(app: params[:app]) if APPS.include?(params[:app])
      paginate(matches, params, path, opt)
    end
  end
end
