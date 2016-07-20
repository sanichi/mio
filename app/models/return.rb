class Return < ApplicationRecord
  MIN_YEAR = 2000
  MAX_PERCENT = 1000.0
  MIN_PERCENT = -MAX_PERCENT

  belongs_to :returnable, polymorphic: true

  default_scope { order(year: :desc) }

  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: MIN_YEAR }, uniqueness: { scope: [:returnable_type, :returnable_id] }
  validates :percent, numericality: { greater_than: MIN_PERCENT, less_than: MAX_PERCENT }
  validate :year_cannot_be_in_future

  def financial_year
    "#{year - 1}-#{year.to_s[2,2]}"
  end

  def formatted_percent
    "%.01f" % percent
  end

  private

  def year_cannot_be_in_future
    errors.add(:year, "can't be in the future") if year.to_i > Date.today.year
  end
end
