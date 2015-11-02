class HistoricalEvent < ActiveRecord::Base
  MAX_DESC = 50
  MIN_YR = 1700

  before_validation :tidy_text

  validates :start, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YR }
  validates :finish, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YR }
  validates :description, presence: true, length: { maximum: MAX_DESC }

  validate :years_must_make_sense

  scope :by_year, -> { order(:start, :finish) }

  private

  def tidy_text
    description.squish! unless description.nil?
  end

  def years_must_make_sense
    if start.present? && finish.present?
      errors.add(:finish, "can't finish before start") if finish < start
    end
  end
end
