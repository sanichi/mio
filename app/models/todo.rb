class Todo < ApplicationRecord
  MAX_DESC = 60
  PRIORITIES = [0, 1, 2, 3, 4]

  before_validation :canonicalize

  validates :priority, inclusion: { in: PRIORITIES }
  validates :description, presence: true, length: { maximum: MAX_DESC }, uniqueness: true

  scope :ordered, -> { order(:done, :priority, :description) }

  def highest_priority?
    priority == PRIORITIES.first
  end

  def lowest_priority?
    priority == PRIORITIES.last
  end

  private

  def canonicalize
    description.squish! unless description.nil?
  end
end
