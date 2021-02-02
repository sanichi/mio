class Team < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_NAME = 30
  MAX_SHORT = 15
  MAX_DIVISION = 4
  MIN_DIVISION = 1

  before_validation :normalize_attributes

  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :short, presence: true, length: { maximum: MAX_SHORT }, uniqueness: true
  validates :slug, presence: true, length: { maximum: MAX_NAME }, uniqueness: true, format: { with: /\A[a-z]+(-[a-z]+)*\z/ }
  validates :division, numericality: { integer_only: true, more_than_or_equal_to: MIN_DIVISION, less_than_or_equal_to: MAX_DIVISION }

  scope :by_name,    -> { order(:name) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches = by_name
    if sql = cross_constraint(params[:q], %w{name})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  private

  def normalize_attributes
    name&.squish!
    slug&.squish!
    short&.squish!
  end
end
