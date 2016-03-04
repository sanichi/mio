class Resident < ActiveRecord::Base
  include Constrainable
  include Pageable

  MAX_BLOCK = 21
  MIN_BLOCK = 5
  MAX_FLAT = 9
  MIN_FLAT = 1

  has_many :vehicles, dependent: :nullify

  before_validation :canonicalize

  validates :block, numericality: { integer_only: true, greater_than_or_equal_to: MIN_BLOCK, less_than_or_equal_to: MAX_BLOCK }
  validates :flat, numericality: { integer_only: true, greater_than_or_equal_to: MIN_FLAT, less_than_or_equal_to: MAX_FLAT }
  validates :last_name, presence: true, length: { maximum: Person::MAX_LN }, uniqueness: { scope: :first_names }
  validates :first_names, presence: true, length: { maximum: Person::MAX_FN }
  validates :email, format: { with: /\A[^\s@]+@[^\s@]+\z/ }, length: { maximum: User::MAX_EMAIL }, uniqueness: true, allow_nil: true

  scope :by_block_flat,  -> { order(:block, :flat) }
  scope :by_name,  -> { order(:last_name, :first_names) }

  def name
    "#{last_name}, #{first_names}"
  end

  def location
    "#{block}/#{flat}"
  end

  def self.search(params, path, opt={})
    matches = by_name
    if sql = numerical_constraint(params[:block], :block)
      matches = matches.where(sql)
    end
    if sql = numerical_constraint(params[:flat], :flat)
      matches = matches.where(sql)
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
