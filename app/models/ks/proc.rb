module Ks
  class Proc < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Shortenable

    MAX_COMMAND = 100
    MAX_SHORT = 32

    belongs_to :top, class_name: "Ks::Top", foreign_key: :ks_top_id, counter_cache: true

    before_validation :normalize_attributes

    validates :pid, numericality: { only_integer: true, greater_than: 0 }
    validates :mem, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :command, presence: true, length: { maximum: MAX_COMMAND }
    validates :short, length: { maximum: MAX_SHORT }, allow_nil: true

    scope :descending, -> { includes(:top).order(top: { measured_at: :desc }) }
    scope :ascending,  -> { includes(:top).order(top: { measured_at: :asc  }) }
    scope :by_memory,  -> { includes(:top).order(mem: :desc) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "memory"
          by_memory
        when "measured"
          ascending
        else
          descending
        end

      server = params[:server]
      matches = matches.where(top: { server: server }) if SERVERS.include?(server)

      pid = params[:pid].to_i
      matches = matches.where("ks_procs.pid = ?", pid) if pid > 0

      sql = cross_constraint(params[:cmd], %w{command short}, table: "ks_procs")
      matches = matches.where(sql) if sql

      sql = numerical_constraint(params[:mem], "ks_procs.mem")
      matches = matches.where(sql) if sql

      paginate(matches, params, path, opt)
    end

    def normalize_attributes
      self.command = command.truncate(MAX_COMMAND) if command.present? && command.length > MAX_COMMAND
      self.short = short_version(command, MAX_SHORT) if short.blank?
    end
  end
end
