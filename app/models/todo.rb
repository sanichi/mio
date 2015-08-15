class Todo < ActiveRecord::Base
  MAX_DESC = 60
  PRIORITIES = [0, 1, 2, 3, 4]

  validates :priority, inclusion: { in: PRIORITIES }
  validates :description, presence: true, length: { maximum: MAX_DESC }, uniqueness: true

  scope :ordered, -> { order(:priority, :description) }
end
