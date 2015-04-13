class Fund < ActiveRecord::Base
  include Pageable

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :returns, as: :returnable, dependent: :destroy

  CATEGORIES = %w/etf it oeic ut/
  MIN_RRP, MAX_RRP = 1, 7
  MIN_FEE, MAX_FEE = 0.0, 5.0
  SECTORS = [
    "Asia Pacific Ex Japan", "Asia Pacific Inc Japan", "China",
    "Europe Excluding UK", "Europe Including UK", "European Smaller Companies",
    "Flexible Investment", "GBP Corporate Bond", "GBP High Yield", "GBP Strategic Bond",
    "Global", "Global Bonds", "Global Emerging Markets", "Global Emerging Markets Bond", "Global Equity Income",
    "Guaranteed/Protected", "Japan", "Japanese Smaller Companies",
    "Mixed Investment 0-35% Shares", "Mixed Investment 20-60% Shares", "Mixed Investment 40-85% Shares",
    "Money Market", "North America", "North American Smaller Cos",
    "Offshore", "Pension Trusts", "Property", "Short Term Money Market", "Specialist",
    "Targeted Absolute Return", "Technology and Telecoms",
    "UK All Companies", "UK Equity and Bond Income", "UK Equity Income",
    "UK Gilt", "UK Index Linked Gilt", "UK Smaller Companies", "Unclassified"
  ]

  validates :annual_fee, numericality: { greater_than_or_equal_to: MIN_FEE, less_than_or_equal_to: MAX_FEE }
  validates :category, inclusion: { in: CATEGORIES }
  validates :company, :name, presence: true, length: { maximum: 50 }
  validates :risk_reward_profile, numericality: { integer_only: true, greater_than_or_equal_to: MIN_RRP, less_than_or_equal_to: MAX_RRP }
  validates :sector, inclusion: { in: SECTORS }

  def self.search(params, path)
    matches = Fund.all
    matches = where(category: params[:category]) if CATEGORIES.include?(params[:category])
    matches = where("company LIKE '%#{params[:company]}") if params[:company].present?
    matches = where("name LIKE '%#{params[:name]}") if params[:name].present?
    paginate(matches, params, path)
  end

  def formatted_annual_fee
    "%.2f%%" % annual_fee
  end
  
  def average_return(formatted=true)
    return unless returns.size > 0
    average = returns.map(&:percent).reduce(&:+) / returns.size
    formatted ? "%.1f%%" % average : average
  end
end
