class Income < ActiveRecord::Base
  MAX_DESC = 60
  CATEGORIES = %w/mark sandra/
  PERIODS = %w/week month year/

  validates :amount,      numericality: { greater_than: 0.0 }
  validates :category,    inclusion: { in: CATEGORIES }
  validates :description, presence: true, length: { maximum: MAX_DESC }, uniqueness: { scape: :category }
  validates :period,      inclusion: { in: PERIODS }

  validate :date_constraints

  def annual
    ((period == "week" ? 52 : (period == "month" ? 12 : 1)) * amount).round
  end
  
  def full_description
    "#{description} (#{I18n.t("income.category.#{category}")})"
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

  private

  def date_constraints
    if start.present? && finish.present?
      errors.add(:start, "must be before finish") if start > finish
    end
  end
end
