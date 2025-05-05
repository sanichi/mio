module Ks
  class Mem < ActiveRecord::Base
    include Pageable

    belongs_to :journal, class_name: "Ks::Journal", foreign_key: :ks_journal_id, counter_cache: true

    validates :server, inclusion: { in: SERVERS }
    validates :total, :used, numericality: { integer_only: true, greater_than: 0 }
    validates :free, :avail, :swap_used, :swap_free, numericality: { integer_only: true, greater_than_or_equal_to: 0 }
    validates :measured_at, presence: true, uniqueness: { scope: [:server], message: "the same time with the same server" }

    scope :descending, -> { order(measured_at: :desc, server: :desc) }
    scope :ascending,  -> { order(measured_at: :asc,  server: :desc) }

    def self.import(dir, server, journal)
      begin
        name = "mem"
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
          if Ks::Mem.find_by(measured_at: time, server: server)
            journal.add_warning("line #{num} (#{line}) of #{path} is a duplicate")
            next
          end
          raise "line #{num} (#{line}) of #{path} has can't be parsed into 6 numbers" unless line.match(/\s(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*\z/)
          journal.mems.create!(measured_at: time, server: server, total: $1, used: $2, free: $3, avail: $4, swap_used: $5, swap_free: $6)
        end
        journal.add_neatly(path, num)

        tmp = dir + "mem.tmp"
        system("mv #{file} #{tmp}")
      rescue => e
        journal.add_error(e.message)
      end
    end

    def self.search(params, path, opt={})
      matches = params[:order] == "asc" ? ascending : descending
      matches = matches.where(server: params[:server]) if SERVERS.include?(params[:server])
      paginate(matches, params, path, opt)
    end
  end
end

