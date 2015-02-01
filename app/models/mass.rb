class Mass < ActiveRecord::Base
  include Pageable

  MIN_KG, MAX_KG = 60, 120

  validates :start, :finish, numericality: { greater_than_or_equal_to: MIN_KG, less_than_or_equal_to: MAX_KG }, allow_nil: true
  validates :date, presence:true, uniqueness: true

  validate :data_constraints

  scope :ordered, -> { order(date: :desc) }

  def self.search(params, path, opt={})
    matches = ordered
    paginate(matches, params, path, opt)
  end

  private

  def data_constraints
    if start.blank? && finish.blank?
      errors.add(:start, "must have at least 1 measurement")
      errors.add(:finish, "must have at least 1 measurement")
    end
  end
end
