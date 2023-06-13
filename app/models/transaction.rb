class Transaction < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_ACCOUNT = 4
  MAX_AMOUNT = 1000000.0
  MAX_CATEGORY = 3
  MAX_DESCRIPTION = 100
  ACCOUNTS = {
    "831909-234510" => "mrbs",
    "831909-101456" => "jrbs",
  }

  validates :account, inclusion: { in: ACCOUNTS.values }
  validates :amount, :balance, numericality: { greater_than_or_equal_to: -MAX_AMOUNT, less_than_or_equal_to: MAX_AMOUNT }
  validates :category, format: { with: /\A[A-Z][\/A-Z][A-Z]\z/ }
  validates :date, presence: true
  validates :description, presence: true, length: { maximum: MAX_DESCRIPTION }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "amount_asc"
      order(amount: :asc)
    when "amount_desc"
      order(amount: :desc)
    when "balance_asc"
      order(balance: :asc)
    when "balance_desc"
      order(balance: :desc)
    when "date_asc"
      order(date: :asc)
    when "date_desc"
      order(date: :desc)
    else
      order(date: :asc)
    end
    if params[:account].present?
      matches = matches.where(account: params[:account])
    end
    if params[:category].present?
      matches = matches.where(category: params[:category])
    end
    if sql = cross_constraint(params[:description], %w{description})
      matches = matches.where(sql)
    end
    if sql = numerical_constraint(params[:amount], :amount)
      matches = matches.where(sql)
    end
    if sql = numerical_constraint(params[:balance], :balance)
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end
end
