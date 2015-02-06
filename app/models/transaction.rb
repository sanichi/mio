require 'csv'

class Transaction < ActiveRecord::Base
  include Pageable

  MAX_STRING = 255
  MAX_SETTLE = 10

  belongs_to :upload

  before_validation :correct_whitespace, :adjust_data

  validates :account,     inclusion: { in: Upload::ACCOUNTS, message: "unexpected value (%{value})" }
  validates :cost,        numericality: { greater_than_or_equal_to: 0.0 }, allow_nil: true
  validates :description, presence: true, length: { maximum: MAX_STRING }
  validates :quantity,    numericality: { greater_than_or_equal_to: 0, integer_only: true }, allow_nil: true
  validates :reference,   presence: true, length: { maximum: MAX_STRING }
  validates :settle_date, presence: true
  validates :signature,   presence:true, uniqueness: true
  validates :trade_date,  presence: true
  validates :upload_id,   numericality: { greater_than: 0, integer_only: true }
  validates :value,       numericality: true

  validate :date_constraints

  scope :ordered, -> { order(trade_date: :desc, reference: :asc, description: :asc) }

  def self.extract(upload)
    accepted, rejected = 0, 0
    line_number = nil
    data_rows_with_line_numbers(upload.content).each do |row|
      line_number = row.pop
      if signature = get_and_check_signature(row)
        create_transaction(row, upload, signature)
        accepted += 1
      else
        rejected += 1
      end
    end
    upload.update(error: possible_error_or_warning(accepted, rejected))
  rescue ActiveRecord::RecordInvalid => e
    upload.update(error: "line #{line_number}: #{e.message}")
  end

  def self.search(params, path, opt={})
    matches = ordered
    matches = matches.where(upload_id: params[:upload_id].to_i) if params[:upload_id].to_i > 0
    matches = matches.where("description LIKE ?", "%#{params[:description]}%") if params[:description].present?
    matches = matches.where("reference LIKE ?", "%#{params[:reference]}%") if params[:reference].present?
    paginate(matches, params, path, opt)
  end

  private

  def date_constraints
    if settle_date.present? && settle_date > Date.today.days_since(MAX_SETTLE)
      errors.add(:settle_date, "can't be more than #{MAX_SETTLE} days in the future")
    end
    if trade_date.present? && trade_date > Date.today
      errors.add(:trade_date, "can't be in the future")
    end
  end

  def correct_whitespace
    description.squish! if description.present?
    reference.squish! if reference.present?
  end

  def adjust_data
    # Computercentre shares changed name and did a swap.
    if description.match(/Computacenter/)
      self.description = "Computacenter plc Ord 6 2/3p"
      self.quantity = 167 if quantity == 186
    end

    # Apple did a 7-for-1 swap.
    if description == "Apple Inc Com Stk NPV (CDI)" && quantity == 3
      self.quantity = 21
    end

    # Management fees tend to have different descriptions but the same reference.
    if reference == "MANAGE FEE"
      self.description = "Management Fee"
    end
  end

  class << self
    private

    def data_rows_with_line_numbers(content)
      headers, line_number = true, 0
      ::CSV.parse(content).map do |row|
        line_number += 1
        if row.empty? || row[0].blank?
          nil
        elsif headers
          headers = false if row[0] == "Trade date"
          nil
        else
          row.push(line_number)
        end
      end.compact
    end

    def get_and_check_signature(row)
      sig = Digest::MD5.hexdigest(row.join("|"))
      return nil if where(signature: sig).count > 0
      sig
    end

    def create_transaction(row, upload, signature)
      create! do |t|
        t.trade_date  = Date.parse(row[0])
        t.settle_date = Date.parse(row[1])
        t.reference   = row[2]
        t.description = row[3]
        t.cost        = row[4].present?? row[4].gsub(/,/, "").to_f : nil
        t.quantity    = row[5].present?? row[5].gsub(/,/, "").to_i : nil
        t.value       = row[6].present?? row[6].gsub(/,/, "").to_f : nil
        t.upload_id   = upload.id
        t.account     = upload.account
        t.signature   = signature
      end
    end

    def possible_error_or_warning(accepted, rejected)
      case
      when accepted == 0 && rejected == 0 then "No transactions detected"
      when accepted == 0 && rejected >= 1 then "All transactions (#{rejected}) are duplicates"
      when accepted >= 1 && rejected >= 1 then "Some transactions (#{rejected}) are duplicates"
      end
    end
  end
end
