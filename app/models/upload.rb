class Upload < ActiveRecord::Base
  attr_accessor :file

  TYPES = %w[text/plain text/csv]
  MAX_SIZE = 1.megabyte

  before_validation :process_file
  after_validation :transfer_error

  validates :content, presence: true, length: { maximum: MAX_SIZE }
  validates :error, length: { maximum: 256 }, allow_nil: true
  validates :name, presence: true, length: { maximum: 256 }
  validates :content_type, inclusion: { in: TYPES, message: "unexpected value (%{value})" }
  validates :size, numericality: { integer_only: true, less_than_or_equal_to: MAX_SIZE }

  private

  def process_file
    return unless new_record?
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

  def transfer_error
    return if errors.empty? || errors[:file].any?
    errors.add :file, errors.full_messages.first
  end
end
