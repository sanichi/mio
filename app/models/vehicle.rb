class Vehicle < ActiveRecord::Base
  include Pageable

  MAX_REG = 12
  MAX_DESC = 20

  belongs_to :resident
  has_many :parkings, dependent: :destroy

  before_validation :canonicalize

  validates :description, presence: true, length: { maximum: MAX_DESC }
  validates :registration, presence: true, length: { maximum: MAX_REG }, format: { with: /\A[A-Z0-9]+( [A-Z0-9]+){0,3}\z/ }, uniqueness: true
  validates :resident_id, numericality: { integer_only: true, greater_than: 0 }, allow_nil: true

  scope :by_registration,  -> { order(:registration) }

  def self.search(params, path, opt={})
    matches = by_registration
    matches = matches.includes(:resident).joins("LEFT JOIN residents ON vehicles.resident_id = residents.id")
    if (q = params[:description]).present?
      matches = matches.where("description ILIKE ?", "%#{q}%")
    end
    if (q = params[:registration]).present?
      matches = matches.where("registration ILIKE ?", "%#{q}%")
    end
    if (q = params[:owner]).present?
      matches = matches.where("residents.first_names ILIKE ? OR residents.last_name ILIKE ?", "%#{q}%", "%#{q}%")
    end
    paginate(matches, params, path, opt)
  end

  def self.match(reg)
    return [] if reg.blank?
    where("registration ILIKE '%#{reg}%'").by_registration.map do |vehicle|
      { id: vehicle.id, value: vehicle.registration }
    end
  end

  private

  def canonicalize
    description&.squish!
    registration&.squish!&.upcase!
  end
end
