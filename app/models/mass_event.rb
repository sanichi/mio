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

  def self.events() = order(:start).to_a.map{|e| [e.name, e.start.to_fs(:db), (e.finish - e.start).to_i + 1]}

  private

  def normalize_attributes
    name&.squish!
    name&.gsub!(/['"]/, "")
  end

  def date_constraints
    if start.present? && finish.present?
      if finish < start
        errors.add(:finish, "must be on or after Start")
      else
        today = Date.today
        errors.add(:start, "must not be in the future #{start.to_fs(:db)}") if start > today
        errors.add(:finish, "must not be in the future #{finish.to_fs(:db)}") if finish > today
      end
    end
  end
end
