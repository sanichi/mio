module Ks
  class Journal < ActiveRecord::Base
    include Constrainable
    include Pageable

    NEAT = 20
    PROTECTED = [   # see lib/tasks/kanshi.rake, task kanshi:prune
      "2025-05-05", # severe cpu and memory problems on hokkaido leading to reboot
      "2025-05-07", # high swap on morioka possibly due to packagekit leading to reboot
      "2025-05-12", # packagekit-like surge, kanshi logging interupted
    ]

    has_many :boots, foreign_key: :ks_journal_id, dependent: :destroy
    has_many :mems,  foreign_key: :ks_journal_id, dependent: :destroy
    has_many :tops,  foreign_key: :ks_journal_id, dependent: :destroy
    has_many :cpus,  foreign_key: :ks_journal_id, dependent: :destroy

    validates :procs_count, :pcpus_count, :warnings, :problems, numericality: { integer_only: true, greater_than_or_equal_to: 0 }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "created"
          order(created_at: :asc)
        when "warnings"
          order(warnings: :desc)
        when "problems"
          order(problems: :desc)
        else
          order(created_at: :desc)
        end

      sql = numerical_constraint(params[:warnings], :warnings)
      matches = matches.where(sql) if sql

      sql = numerical_constraint(params[:problems], :problems)
      matches = matches.where(sql) if sql

      paginate(matches, params, path, opt)
    end

    def add_message(msg)
      self.note += "#{msg}\n"
    end

    def add_warning(msg)
      self.warnings += 1
      self.note += "WARNING: #{msg}\n"
    end

    def add_error(msg)
      self.problems += 1
      self.note += "ERROR: #{msg}\n"
    end

    def add_neatly(msg, count)
      add_message("%s%s %s" % [msg, "." * (msg.length >= NEAT ? 0 : NEAT - msg.length), count])
    end

    def okay?() = problems == 0
  end
end
