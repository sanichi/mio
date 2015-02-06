class Upload < ActiveRecord::Base
  include Pageable

  attr_accessor :file

  ACCOUNTS = %w[cap inc]
  TYPES = %w[csv comma-separated-values plain].map { |t| "text/#{t}" }
  MAX_SIZE = 1.megabyte
  MAX_STRING = 255

  has_many :transactions, dependent: :destroy

  before_validation :process_file, :truncate_error
  after_validation :transfer_error_to_file_field
  after_create :extract_transactions

  validates :account, inclusion: { in: ACCOUNTS, message: "unexpected value (%{value})" }
  validates :content, presence: true, length: { maximum: MAX_SIZE }
  validates :content_type, inclusion: { in: TYPES, message: "unexpected value (%{value})" }
  validates :error, length: { maximum: MAX_STRING }, allow_nil: true
  validates :name, presence: true, length: { maximum: MAX_STRING }
  validates :size, numericality: { integer_only: true, less_than_or_equal_to: MAX_SIZE }

  scope :ordered, -> { order(created_at: :desc) }

  def self.search(params, path, opt={})
    matches = ordered
    paginate(matches, params, path, opt)
  end

  private

  def process_file
    return unless new_record? && content.blank?
    if file.is_a? ActionDispatch::Http::UploadedFile
      self.content      = utf8_data
      self.name         = file.original_filename
      self.size         = file.size
      self.content_type = file.content_type
    else
      errors.add(:file, "missing file")
    end
  end

  def utf8_data
    data = file.read
    utf8 = data.force_encoding("UTF-8")
    return utf8 if utf8.valid_encoding?
    data.encode("UTF-8", "Windows-1252")
  rescue EncodingError
    data.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
  end

  def truncate_error
    self.error = error[0, MAX_STRING] if error.present? && error.length > MAX_STRING
  end

  def transfer_error_to_file_field
    if errors.any? && errors[:file].empty?
      errors.add :file, errors.full_messages.first
    end
  end

  def extract_transactions
    Transaction.extract(self)
  end
end
