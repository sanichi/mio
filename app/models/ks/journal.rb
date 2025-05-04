module Ks
  class Journal < ActiveRecord::Base
    include Pageable
    NEAT = 20

    validates :boot, :mem, :top, :proc, :warnings, :problems, numericality: { integer_only: true, greater_than_or_equal_to: 0 }

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
      matches.each { |m| logger.info "XXXXXXXXXX #{m.id} #{m.created_at.to_fs(:db)}" }
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
