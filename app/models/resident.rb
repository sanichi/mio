class Resident < ActiveRecord::Base
  include Pageable

  MAX_ADDR = 200

  has_many :vehicles, dependent: :nullify
  has_many :ownerships, class_name: "Flat", foreign_key: "owner_id", dependent: :nullify
  has_many :tenancies, class_name: "Flat", foreign_key: "tenant_id", dependent: :nullify
  has_many :lordships, class_name: "Flat", foreign_key: "landlord_id", dependent: :nullify

  before_validation :canonicalize

  validates :last_name, presence: true, length: { maximum: Person::MAX_LN }, uniqueness: { scope: :first_names }
  validates :first_names, presence: true, length: { maximum: Person::MAX_FN }
  validates :email, format: { with: /\A[^\s@]+@[^\s@]+\z/ }, length: { maximum: User::MAX_EMAIL }, uniqueness: true, allow_nil: true

  scope :by_name,  -> { order(:last_name, :first_names) }

  def name
    "#{last_name}, #{first_names}"
  end

  def location
    "#{block}/#{flat}"
  end

  def self.search(params, path, opt={})
    matches = by_name.includes(:vehicles).includes(:ownerships).includes(:tenancies)
    if (q = params[:first_names]).present?
      matches = matches.where("first_names ILIKE ?", "%#{q}%")
    end
    if (q = params[:last_name]).present?
      matches = matches.where("last_name ILIKE ?", "%#{q}%")
    end
    paginate(matches, params, path, opt)
  end

  private

  def canonicalize
    address&.squish!
    email&.squish!
    name&.squish!
    self.email = nil if email.blank?
    self.address = nil if address.blank?
  end
end
