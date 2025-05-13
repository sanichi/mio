module Ks
  class Pcpu < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Shortenable

    MAX_COMMAND = 100
    MAX_SHORT = 32
    MAX_PCPU = 999.9

    belongs_to :cpu, class_name: "Ks::Cpu", foreign_key: :ks_cpu_id, counter_cache: true

    before_validation :normalize_attributes

    validates :pid, numericality: { only_integer: true, greater_than: 0 }
    validates :pcpu, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: MAX_PCPU }
    validates :command, presence: true, length: { maximum: MAX_COMMAND }
    validates :short, length: { maximum: MAX_SHORT }, allow_nil: true

    scope :descending, -> { includes(:cpu).order(cpu: { measured_at: :desc }) }
    scope :ascending,  -> { includes(:cpu).order(cpu: { measured_at: :asc  }) }
    scope :by_pcpu,    -> { includes(:cpu).order(pcpu: :desc) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "pcpu"
          by_pcpu
        when "measured"
          ascending
        else
          descending
        end

      server = params[:server]
      matches = matches.where(cpu: { server: server }) if SERVERS.include?(server)

      pid = params[:pid].to_i
      matches = matches.where("ks_pcpus.pid = ?", pid) if pid > 0

      sql = cross_constraint(params[:cmd], %w{command short}, table: "ks_pcpus")
      matches = matches.where(sql) if sql

      sql = numerical_constraint(params[:pcpu], "ks_pcpus.pcpu", digits: 1)
      matches = matches.where(sql) if sql

      paginate(matches, params, path, opt)
    end

    def normalize_attributes
      self.command = command.truncate(MAX_COMMAND) if command.present? && command.length > MAX_COMMAND
      self.short = short_version(command, MAX_SHORT) if short.blank?
      self.pcpu = MAX_PCPU if pcpu.to_f > MAX_PCPU
    end
  end
end
