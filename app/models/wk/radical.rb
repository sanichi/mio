module Wk
  class Radical < ActiveRecord::Base
    include Constrainable
    include Pageable

    MAX_NAME = 32

    validates :character, length: { is: 1 }, uniqueness: true, allow_nil: true
    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
    validates :mnemonic, presence: true
    validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    scope :by_name,  -> { order(:name) }
    scope :by_level, -> { order(:level, :name) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "level" then by_level
        else              by_name
        end
      if sql = cross_constraint(params[:query], %w{name character})
        matches = matches.where(sql)
      end
      if (level = params[:level].to_i) > 0
        matches = matches.where(level: level)
      end
      paginate(matches, params, path, opt)
    end
  end
end
