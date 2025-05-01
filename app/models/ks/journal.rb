module Ks
  class Journal < ActiveRecord::Base
    include Pageable

    validates :boot, :mem, :top, :proc, :warnings, numericality: { integer_only: true, greater_than_or_equal_to: 0 }

    default_scope { order(created_at: :desc) }

    def self.search(params, path, opt={})
      matches = all
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
      self.okay = false
      self.note += "ERROR: #{msg}\n"
    end
  end
end
