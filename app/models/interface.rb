class Interface < ActiveRecord::Base
  include Constrainable
  include Pageable

  MAX_ADDR = 17
  MAX_IPAD = 15
  MAX_MANU = 50
  MAX_NAME = 50

  belongs_to :device

  before_validation :canonicalize

  validates :mac_address, format: { with: /\A[0-9A-F]{2}(:[0-9A-F]{2}){5}\z/ }
  validates :device_id, numericality: { integer_only: true, greater_than: 0 }
  validates :ip_address, format: { with: /\A\d{1,3}(\.\d{1,3}){3}\z/ }
  validates :manufacturer, presence: true, length: { maximum: MAX_MANU }, allow_nil: true
  validates :name, presence: true, length: { maximum: MAX_NAME }

  scope :ordered, -> { order(:name) }

  def self.search(params, path, opt={})
    matches = ordered
    if (constraint = cross_constraint(params[:q], cols: %w/ip_address mac_address manufacturer name/))
      matches = matches.where(constraint)
    end
    paginate(matches, params, path, opt)
  end

  private

  def canonicalize
    self.ip_address = "" if ip_address.blank?
    ip_address.gsub!(/\D/, ".")
    ip_address.gsub!(/\.\.+/, ".")
    ip_address.sub!(/\A\.+/, "")
    ip_address.sub!(/\.+\z/, "")
    self.mac_address = "" if mac_address.blank?
    mac_address.upcase!
    mac_address.gsub!(/[^0-9A-F]/, ":")
    mac_address.gsub!(/::+/, ":")
    mac_address.sub!(/\A:+/, "")
    mac_address.sub!(/:+\z/, "")
    manufacturer&.squish!
    name&.squish!
    self.manufacturer = nil if manufacturer.blank?
  end
end
