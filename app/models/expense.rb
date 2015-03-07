class Expense < ActiveRecord::Base
  MAX_DESC = 30
  CATEGORIES = %w/house mark sandra/
  PERIODS = %w/week month year/

  validates :amount,      numericality: { greater_than: 0.0 }
  validates :category,    inclusion: { in: CATEGORIES }
  validates :description, presence: true, length: { maximum: MAX_DESC }
  validates :period,      inclusion: { in: PERIODS }

  def annualized
    ((period == "week" ? 52 : (period == "month" ? 12 : 1)) * amount).round
  end
end
