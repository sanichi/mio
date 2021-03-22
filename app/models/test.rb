class Test < ApplicationRecord
  include Pageable

  MAX_LEVEL = 9
  MIN_LEVEL = 0
  LAST = %w/poor fair good excellent skip/

  belongs_to :testable, polymorphic: true

  validates :attempts, :poor, :fair, :good, :excellent, numericality: { integer_only: true, more_than_or_equal_to: 0 }
  validates :level, numericality: { integer_only: true, more_than_or_equal_to: MIN_LEVEL, less_than_or_equal_to: MAX_LEVEL }
  validates :last, inclusion: { in: LAST }, allow_nil: true

  scope :by_new,       -> { order(due:        :desc) }
  scope :by_due,       -> { order(due:        :asc)  }
  scope :by_attempts,  -> { order(attempts:   :desc) }
  scope :by_poor,      -> { order(poor:       :desc) }
  scope :by_fair,      -> { order(fair:       :desc) }
  scope :by_good,      -> { order(good:       :desc) }
  scope :by_excellent, -> { order(excellent:  :desc) }
  scope :by_level,     -> { order(level:      :desc) }
  scope :by_updated,   -> { order(updated_at: :desc) }

  def self.search(params, path, opt={})
    matches =
      case params[:order]
      when "attempts"
        by_attempts
      when "due"
        by_due
      when "excellent"
        by_excellent
      when "fair"
        by_fair
      when "good"
        by_good
      when "level"
        by_level
      when "new"
        by_new
      when "poor"
        by_poor
      when "updated"
        by_updated
      else
        by_due
      end
    matches =
      case params[:type]
      when "example"
        matches.where(testable_type: "Wk::Example")
      when "place"
        matches.where(testable_type: "Place")
      when "border"
        matches.where(testable_type: "Border")
      else
        matches
      end
    matches = matches.where(last: params[:last]) if LAST.include? params[:last]
    paginate(matches, params, path, opt)
  end
end
