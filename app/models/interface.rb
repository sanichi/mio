class Interface < ActiveRecord::Base
  include Pageable

  MAX_ADDR = 17
  MAX_NAME = 50

  belongs_to :device

  before_validation :canonicalize

  validates :address, format: { with: /\A[0-9A-F]{2}(:[0-9A-F]{2}){5}\z/ }
  validates :device_id, numericality: { integer_only: true, greater_than: 0 }
  validates :name, presence: true, length: { maximum: MAX_NAME }

  scope :ordered, -> { order(:name) }

  def self.search(params, path, opt={})
    matches = ordered
    paginate(matches, params, path, opt)
  end

  private

  def canonicalize
    self.address = "" if address.blank?
    address.upcase!
    address.gsub!(/[^0-9A-F]/, ":")
    address.gsub!(/::+/, ":")
    address.sub!(/\A:+/, "")
    address.sub!(/:+\z/, "")
    name&.squish!
  end
end
