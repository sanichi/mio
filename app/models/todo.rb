class Todo < ActiveRecord::Base
  MAX_DESC = 60
  PRIORITIES = [0, 1, 2, 3, 4]

  validates :priority, inclusion: { in: PRIORITIES }
  validates :description, presence: true, length: { maximum: MAX_DESC }, uniqueness: true

  scope :ordered, -> { order(:done, :priority, :description) }

  def to_json
    as_json(except: [:created_at, :updated_at], methods: :priority_)
  end

  def priority_
    I18n.t("todo.priorities")[priority]
  end
end
