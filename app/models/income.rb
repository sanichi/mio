class Income < ActiveRecord::Base
  MAX_DESC = 60
  CATEGORIES = %w/mark sandra/
  PERIODS = %w/week month year/

  validates :amount,      numericality: { greater_than: 0.0 }
  validates :category,    inclusion: { in: CATEGORIES }
  validates :description, presence: true, length: { maximum: MAX_DESC }
  validates :period,      inclusion: { in: PERIODS }

  def annual
    ((period == "week" ? 52 : (period == "month" ? 12 : 1)) * amount).round
  end

  def self.search(params)
    category = params[:category]
    if CATEGORIES.include?(category)
      matches = where(category: category).all
    else
      matches = all
      category = "all"
    end
    [matches.sort_by(&:annual).reverse, category]
  end
end
