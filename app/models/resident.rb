class Resident < ActiveRecord::Base
  include Constrainable
  include Pageable

  MAX_BAY = 86
  MIN_BAY = 0
  MAX_BLOCK = 21
  MIN_BLOCK = 5
  MAX_FLAT = 9
  MIN_FLAT = 1

  before_validation :canonicalize

  validates :bay, numericality: { integer_only: true, greater_than_or_equal_to: MIN_BAY, less_than_or_equal_to: MAX_BAY }
  validates :block, numericality: { integer_only: true, greater_than_or_equal_to: MIN_BLOCK, less_than_or_equal_to: MAX_BLOCK }
  validates :flat, numericality: { integer_only: true, greater_than_or_equal_to: MIN_FLAT, less_than_or_equal_to: MAX_FLAT }
  validates :last_name, presence: true, length: { maximum: Person::MAX_LN }, uniqueness: { scape: :first_names }
  validates :first_names, presence: true, length: { maximum: Person::MAX_FN }
  validates :email, format: { with: /\A[^\s@]+@[^\s@]+\z/ }, length: { maximum: User::MAX_EMAIL }, uniqueness: true, allow_nil: true

  scope :by_block_flat,  -> { order(:block, :flat) }

  def name
    "#{first_names} #{last_name}"
  end

  def location
    "#{block}/#{flat}"
  end

  def self.search(params, path, opt={})
    matches = by_block_flat
    if sql = numerical_constraint(params[:block], :block)
      matches = matches.where(sql)
    end
    if sql = numerical_constraint(params[:flat], :flat)
      matches = matches.where(sql)
    end
    if sql = numerical_constraint(params[:bay], :bay)
      matches = matches.where(sql).where.not(bay: 0)
    end
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
    email&.squish!
    name&.squish!
    self.email = nil unless email.present?
  end
end
