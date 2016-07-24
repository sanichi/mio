class Tax < ApplicationRecord
  ANNUAL_ALLOWANCE = Hash.new(1100)
  ANNUAL_ALLOWANCE[0] = 933
  MAX_DESC = 100
  START_YEAR = 2016
  TAX_RATE = Hash.new(20)

  validates :description, presence: true, length: { maximum: MAX_DESC }, uniqueness: { scope: :year_number }
  validates :free, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :income, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: 30000 }
  validates :paid, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 30000 }
  validates :times, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: 53 }
  validates :year_number, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 40 }

  scope :by_description, -> { order(:description) }

  def self.search(year_number)
    Tax.where(year_number: year_number).by_description
  end

  def self.current_year_number
    Date.today.year - START_YEAR - (Date.today.month < 4 ? 1 : 0)
  end

  def self.tax_year(n)
    "#{n + START_YEAR}-#{(n + START_YEAR + 1) % 100}"
  end

  def tax_year
    self.class.tax_year(year_number)
  end
end
