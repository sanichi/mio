class Income < ActiveRecord::Base
  MAX_DESC = 60
  CATEGORIES = %w/mark sandra/
  PERIODS = %w/week month year/

  validates :amount,      numericality: { greater_than: 0.0 }
  validates :joint,       numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :category,    inclusion: { in: CATEGORIES }
  validates :description, presence: true, length: { maximum: MAX_DESC }, uniqueness: { scope: :category }
  validates :period,      inclusion: { in: PERIODS }

  validate :date_constraints

  def annual(joint: true)
    if joint
      @joint_amount ||= ((period == "week" ? 52 : (period == "month" ? 12 : 1)) * amount * (self.joint / 100.0)).round
    else
      @total_amount ||= ((period == "week" ? 52 : (period == "month" ? 12 : 1)) * amount).round
    end
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
