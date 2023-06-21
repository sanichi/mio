require 'csv'

class Transaction < ApplicationRecord
  include Constrainable
  include Pageable

  class_attribute :classifiers

  MAX_ACCOUNT = 4
  MAX_AMOUNT = 1000000.0
  MAX_CATEGORY = 3
  MAX_DESCRIPTION = 100
  ACCOUNTS = {
    "831909-234510"    => "mrbs",
    "831909-101456"    => "jrbs",
    "543484******5254" => "mcc",
  }

  after_save :classify

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
      order(date: :desc)
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
    if sql = numerical_constraint(params[:upload_id], :upload_id)
      matches = matches.where(sql)
    end
    if (classifier_id = params[:classifier_id].to_i) != 0
      classifier_id = nil if classifier_id < 0
      matches = matches.where(classifier_id: classifier_id)
    end
    paginate(matches, params, path, opt)
  end

  def self.last_upload_id() = maximum(:upload_id).to_i

  def self.upload(path, upload_id)
    rows = 0
    created = 0
    duplicates = 0
    account = nil
    self.classifiers = Classifier.all

    transaction do
      begin
        CSV.foreach(path) do |row|
          rows += 1
          next if row.empty?
          raise "wrong number of columns (#{row.size}) on row #{rows}" if row.size < 7 || row.size > 8
          next if row[0].squish == "Date"

          account = check_account(row[6], rows, account)

          case account
          when "mrbs", "jrbs"
            date, category, description, amount, balance, skip = rbs_ac(row, rows)
          when "mcc"
            date, category, description, amount, balance, skip = rbs_cc(row, rows)
          end

          next if skip

          transaction = find_by(date: date, category: category, description: description, amount: amount, balance: balance, account: account)

          if transaction
            duplicates += 1
          else
            create!(date: date, category: category, description: description, amount: amount, balance: balance, account: account, upload_id: upload_id)
            created += 1
          end
        end
      rescue => e
        raise e
      ensure
        self.classifiers = nil
      end
    end

    raise "no records found" unless created > 0 || duplicates > 0

    "rows: #{rows}, created: #{created}, duplicates: #{duplicates}, upload: #{upload_id}"
  end

  def self.check_account(text, rows, current)
    text.squish!.sub!(/\A\s*'/, "")
    account = ACCOUNTS[text]
    raise "invalid account (#{text}) on row #{rows}" unless account
    raise "changed account (#{current} => #{account}) on row #{rows}" if current && current != account
    account
  end

  def self.rbs_ac(row, rows)
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
    [date, category, description, amount, balance, false]
  end

  def self.rbs_cc(row, rows)
    if row[1].blank? && row[2].match?(/Balance/i) && row[4].present?
      return [nil, nil, nil, nil, nil, true]
    end
    date = begin
      Date.parse(row[0])
    rescue
      raise "invalid date #{row[0]} on row #{rows}"
    end
    category = case row[1].squish
    when "Payment"
      "PAY"
    when "Purchase"
      "PUR"
    when "Fee"
      "FEE"
    else
      raise "unrecognised category (#{row[1]}) on row #{rows}"
    end
    description = row[2].sub(/\A\s*'/, "").squish
    amount = begin
      row[3].to_f
    rescue
      raise "invalid amount (#{row[3]}) on row #{rows}"
    end
    amount *= -1
    raise "unexpected balance (#{row[4]}) on row #{rows}" if row[4].present?
    balance = 0.0
    [date, category, description, amount, balance, false]
  end

  private

  def classify
    classifiers = self.class.classifiers || Classifier.all
    classifiers.each do |c|
      if match?(c)
        update_column(:classifier_id, c.id)
        break
      end
    end
  end
end
