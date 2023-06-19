require 'csv'

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

  belongs_to :classifier, optional: true, inverse_of: :transactions

  validates :account, inclusion: { in: ACCOUNTS.values }
  validates :amount, :balance, numericality: { greater_than_or_equal_to: -MAX_AMOUNT, less_than_or_equal_to: MAX_AMOUNT }
  validates :category, format: { with: /\A[A-Z][\/A-Z][A-Z]\z/ }
  validates :date, presence: true
  validates :description, presence: true, length: { maximum: MAX_DESCRIPTION }
  validates :upload_id, numericality: { integer_only: true, greater_than: 0 }

  def match?(c)
    return false unless c.is_a?(Classifier)
    return false unless category.match?(c.cre)
    return false if amount > c.max_amount
    return false if amount < c.min_amount
    return false unless description.match?(c.dre)
    return true
  end

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
    if (upload_id = params[:upload_id].to_i) > 0
      matches = matches.where(upload_id: upload_id)
    end
    paginate(matches, params, path, opt)
  end

  def self.last_upload_id() = maximum(:upload_id).to_i

  def self.upload(path, upload_id)
    rows = 0
    created = 0
    duplicates = 0
    CSV.foreach(path) do |row|
      rows += 1
      next if row.empty?
      raise "wrong number of columns (#{row.size}) on row #{rows}" unless row.size == 7
      next if row[0] == "Date"

      date = begin
        Date.parse(row[0])
      rescue
        raise "invalid date #{row[0]} on row #{rows}"
      end
      category = row[1].squish
      description = row[2].squish
      amount = begin
        row[3].to_f
      rescue
        raise "invalid amount (#{row[3]}) on row #{rows}"
      end
      balance = begin
        row[4].to_f
      rescue
        raise "invalid balance (#{row[4]}) on row #{rows}"
      end
      account = ACCOUNTS[row[6].squish]
      raise "invalid account (#{row[6]}) on row #{rows}" unless account.present?

      transaction = find_by(date: date, category: category, description: description, amount: amount, balance: balance, account: account)

      if transaction
        transaction.update_column(:upload_id, upload_id)
        duplicates += 1
      else
        create!(date: date, category: category, description: description, amount: amount, balance: balance, account: account, upload_id: upload_id)
        created += 1
      end
    end

    raise "no records found" unless created > 0 || duplicates > 0

    "rows: #{rows}, created: #{created}, duplicates: #{duplicates}"
  end
end
