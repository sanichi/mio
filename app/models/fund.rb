class Fund < ActiveRecord::Base
  include Pageable
  serialize :stars, Array

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :returns, as: :returnable, dependent: :destroy

  default_scope { order(srri: :desc, annual_fee: :asc) }

  CATEGORIES = %w/etf icvc it oeic sicav ut/
  MIN_RRP, MAX_RRP = 1, 7
  MIN_FEE, MAX_FEE = 0.0, 5.0
  MIN_SIZE, MAX_SIZE = 0, 100000
  MAX_COMPANY, MAX_NAME = 50, 70
  STARS = %w[hl_w150p hl_w150 hl_tracker rp_rated]
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

  before_validation :check_stars

  validates :annual_fee, numericality: { greater_than_or_equal_to: MIN_FEE, less_than_or_equal_to: MAX_FEE }
  validates :category, inclusion: { in: CATEGORIES }
  validates :company, presence: true, length: { maximum: MAX_COMPANY }
  validates :name, presence: true, length: { maximum: MAX_NAME }
  validates :srri, numericality: { integer_only: true, greater_than_or_equal_to: MIN_RRP, less_than_or_equal_to: MAX_RRP }
  validates :sector, inclusion: { in: SECTORS }
  validates :size, numericality: { integer_only: true, greater_than_or_eqoal_to: MIN_SIZE, less_than: MAX_SIZE }

  def self.search(params, path, opt={})
    matches = Fund.includes(:comments).includes(:returns)
    matches = where(category: params[:category]) if CATEGORIES.include?(params[:category])
    matches = where("company LIKE '%#{params[:company]}") if params[:company].present?
    matches = where("name LIKE '%#{params[:name]}") if params[:name].present?
    paginate(matches, params, path, opt)
  end

  def formatted_annual_fee
    "%.2f%%" % annual_fee
  end

  def formatted_stars
    stars.map{ |star| I18n.t("fund.stars.short.#{star}") }.join(" ")
  end

  def formatted_srri
    "#{srri}#{srri_estimated ? '*' : ''}"
  end

  def average_return(formatted=true)
    return unless returns.size > 0
    average = returns.map(&:percent).reduce(&:+) / returns.size
    formatted ? "%.1f%%" % average : average
  end

  private

  # Force stars to be valid:
  #   * only valid entries,
  #   * in consistent order,
  #   * at most one with the same prefix.
  def check_stars
    prefix = {}
    self.stars = STARS.select do |star|
      if stars.include?(star)
        if star.match(/\A(\w+_)/)
          if prefix[$1]
            false
          else
            prefix[$1] = true
          end
        else
          true
        end
      else
        false
      end
    end
  end
end
