class VocabTest < ApplicationRecord
  include Pageable

  MAX_CATEGORY = 5
  MAX_COMPLETE = 100
  CATEGORIES = %w(a2mr m2r)

  validates :category, inclusion: { in: CATEGORIES }
  validates :complete, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_COMPLETE }
  validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: Vocab::MAX_LEVEL }

  scope :by_complete, -> { order(complete: :asc, level: :asc) }
  scope :by_level,    -> { order(level: :asc, complete: :asc) }
  scope :by_updated,  -> { order(updated_at: :desc, complete: :asc) }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "complete" then by_complete
    when "level"    then by_level
    else                 by_updated
    end
    matches = matches.where(category: params[:category]) if CATEGORIES.include?(params[:category])
    paginate(matches, params, path, opt)
  end
end
