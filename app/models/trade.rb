class Trade < ApplicationRecord
  include Pageable

  MAX_STOCK = 60

  before_validation :canonicalize

  validates :stock, presence: true, length: { maximum: MAX_STOCK }
  validates :buy_date, :sell_date, presence: true
  validates :units, :buy_price, :sell_price, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validate  :date_constraints

  scope :by_stock, -> { order(:stock) }
  scope :by_profit_desc, -> { order("units * (buy_price - sell_price)") }
  scope :by_profit_asc, -> { order("units * (sell_price - buy_price)") }

  def self.search(params, path, opt={})
    matches =
    case params[:order]
      when "profit_asc"
        by_profit_asc
      when "stock"
        by_stock
      else
        by_profit_desc
    end
    matches = matches.where("stock ILIKE ? ", "%#{params[:stock]}%") if params[:stock].present?
    paginate(matches, params, path, opt)
  end

  def profit
    units * (sell_price - buy_price) / 100.0
  end

  def growth_rate
    36500.0 * (sell_price - buy_price) / (days_held * buy_price)
  end

  def days_held
    (sell_date - buy_date).to_i + 1
  end

  private

  def canonicalize
    stock&.squish!
  end

  def date_constraints
    if buy_date.present? && sell_date.present? && buy_date > sell_date
      errors.add(:sell_date, "cannot sell before buying")
    end
  end
end
