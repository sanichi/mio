class Vehicle < ActiveRecord::Base
  include Pageable

  MAX_REG = 8

  belongs_to :resident

  before_validation :canonicalize

  validates :registration, presence: true, length: { maximum: MAX_REG }, uniqueness: true
  validates :resident_id, numericality: { integer_only: true, greater_than: 0 }, allow_nil: true

  scope :by_registration,  -> { order(:registration) }

  def self.search(params, path, opt={})
    matches = by_registration
    matches = matches.includes(:resident).joins("LEFT JOIN residents ON vehicles.resident_id = residents.id")
    if (q = params[:registration]).present?
      matches = matches.where("registration ILIKE ?", "%#{q}%")
    end
    if (q = params[:owner]).present?
      matches = matches.where("residents.first_names ILIKE ? OR residents.last_name ILIKE ?", "%#{q}%", "%#{q}%")
    end
    paginate(matches, params, path, opt)
  end

  private

  def canonicalize
    registration&.squish!.upcase
  end
end
