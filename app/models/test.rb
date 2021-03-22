class Test < ApplicationRecord
  include Pageable

  MAX_LEVEL = 9
  MIN_LEVEL = 0
  ANSWERS = %w/poor fair good excellent skip/

  belongs_to :testable, polymorphic: true

  after_update :update_stats

  validates :attempts, :poor, :fair, :good, :excellent, numericality: { integer_only: true, more_than_or_equal_to: 0 }
  validates :level, numericality: { integer_only: true, more_than_or_equal_to: MIN_LEVEL, less_than_or_equal_to: MAX_LEVEL }
  validates :last, inclusion: { in: ANSWERS }, allow_nil: true

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
    matches = matches.where(last: params[:last]) if ANSWERS.include? params[:last]
    paginate(matches, params, path, opt)
  end

  private

  def update_stats
    return unless ANSWERS.include?(last)
    return if last == "skip"
    update_column(:attempts, attempts + 1)
    update_column(last, send(last) + 1)
    update_level
    update_due
  end

  def update_level
    new_level = level
    case last
    when "poor"
      new_level -= 2
    when "fair"
      new_level -= 1
    when "good"
      new_level += 1
    when "excellent"
      new_level += 2
    end
    new_level = MIN_LEVEL if new_level < MIN_LEVEL
    new_level = MAX_LEVEL if new_level > MAX_LEVEL
    update_column(:level, new_level)
  end

  def update_due
    new_due = Time.now
    case level
    when 0
      new_due += 12.hours
    when 1
      new_due += 1.day
    when 2
      new_due += 2.days
    when 3
      new_due += 4.days
    when 4
      new_due += 8.days
    when 5
      new_due += 16.days
    when 6
      new_due += 1.month
    when 7
      new_due += 2.months
    when 8
      new_due += 3.months
    when 9
      new_due += 4.months
    end
    update_column(:due, new_due)
  end
end
