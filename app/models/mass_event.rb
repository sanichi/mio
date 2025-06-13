class MassEvent < ApplicationRecord
  include Pageable

  MAX_NAME = 24

  before_validation :normalize_attributes

  validates :name, presence: true, length: { maximum: MAX_NAME }
  validates :start, :finish, presence:true, uniqueness: true
  validate :date_constraints

  def self.search(params, path, opt={})
    matches = order(start: :desc)
    paginate(matches, params, path, opt)
  end

  private

  def normalize_attributes
    name&.squish!
  end

  def date_constraints
    if start.present? && finish.present? && finish < start
      errors.add(:finish, "must be on or after Start")
    end
  end
end
