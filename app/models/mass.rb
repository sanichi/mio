class Mass < ApplicationRecord
  include Pageable

  MIN_KG, MAX_KG = 60, 120
  UNITS = {
    kg: MassUnit.new(:kg, 1.0000, 1,  5),
    lb: MassUnit.new(:lb, 2.2046, 1, 10),
    st: MassUnit.new(:st, 0.1575, 2,  1),
  }
  DEFAULT_UNIT = UNITS[:kg]
  DEFAULT_START = 2 # months ago

  validates :start, :finish, numericality: { greater_than_or_equal_to: MIN_KG, less_than_or_equal_to: MAX_KG }, allow_nil: true
  validates :date, presence:true, uniqueness: true

  validate :data_constraints

  scope :ordered, -> { order(date: :desc) }

  def self.search(params, path, opt={})
    matches = ordered
    paginate(matches, params, path, opt)
  end

  def self.kilos
    ordered.all.each_with_object([]) do |m,a|
      a.push(m.start) if m.start.present?
      a.push(-m.finish) if m.finish.present?
    end
  end

  def self.dates
    ordered.all.each_with_object([]) do |m,a|
      a.push(m.date) if m.start.present?
      a.push(m.date) if m.finish.present?
    end
  end

  def to_json
    as_json(except: [:created_at, :updated_at])
  end

  private

  def data_constraints
    if start.blank? && finish.blank?
      errors.add(:start, "must have at least 1 measurement")
      errors.add(:finish, "must have at least 1 measurement")
    end
  end
end
