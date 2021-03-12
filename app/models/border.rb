class Border < ApplicationRecord
  include Pageable

  DIRS = %w/north south east west northeast northwest southeast southwest/

  belongs_to :from, class_name: "Place"
  belongs_to :to, class_name: "Place"

  validates :from_id, numericality: { integer_only: true, greater_than: 0 }
  validates :to_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: { scope: :from_id }
  validates :direction, inclusion: { in: DIRS }

  validate :check_places

  private

  def check_places
    p1 = Place.find_by(id: from_id)
    p2 = Place.find_by(id: to_id)

    if p1
      errors.add(:from_id, "not a prefecture") unless p1.category == "prefecture"
    else
      errors.add(:from_id, "can't find prefecture")
    end

    if p2
      errors.add(:to_id, "not a prefecture") unless p2.category == "prefecture"
    else
      errors.add(:to_id, "can't find prefecture")
    end

    if p1 && p2 && p1.id == p2.id
      errors.add(:from_id, "prefectures must be distinct")
      errors.add(:to_id, "prefectures must be distinct")
    end
  end
end
