class Trade < ApplicationRecord
  include Pageable

  MAX_STOCK = 60

  before_validation :canonicalize

  validates :stock, presence: true, length: { maximum: MAX_STOCK }
  validates :buy_date, :sell_date, presence: true
  validates :buy_factor, :sell_factor, presence: true, numericality: { greater_than: 0.0 }
  validates :units, :buy_price, :sell_price, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validate  :date_constraints

  scope :by_stock, -> { order(:stock, :sell_date) }
  scope :by_profit_desc, -> { order("units * (buy_price / buy_factor - sell_price / sell_factor)") }
  scope :by_profit_asc, -> { order("units * (sell_price / sell_factor - buy_price / buy_factor)") }
  scope :by_date_desc, -> { order(sell_date: :desc) }
  scope :by_date_asc, -> { order(sell_date: :asc) }

  def self.search(params, path, opt={})
    matches =
    case params[:order]
      when "profit_asc"
        by_profit_asc
      when "profit_desc"
        by_profit_desc
      when "date_asc"
        by_date_asc
      when "stock"
        by_stock
      else
        by_date_desc
    end
    matches = matches.where("stock ILIKE ? ", "%#{params[:stock]}%") if params[:stock].present?
    paginate(matches, params, path, opt)
  end

  def pound_cost
    buy_price / buy_factor
  end

  def pound_sold
    sell_price / sell_factor
  end

  def profit
    units * (pound_sold - pound_cost)
  end

  def growth_rate
    36500.0 * (pound_sold - pound_cost) / (days_held * pound_cost)
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
