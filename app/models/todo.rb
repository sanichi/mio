class Todo < ActiveRecord::Base
  MAX_DESC = 60
  PRIORITIES = [0, 1, 2, 3, 4]

  validates :priority, inclusion: { in: PRIORITIES }
  validates :description, presence: true, length: { maximum: MAX_DESC }, uniqueness: true

  scope :ordered, -> { order(:priority, :description) }

  def self.search(params, path)
    matches = ordered
    matches = matches.where("description ILIKE ?", "%#{params[:description]}%") if params[:description].present?
    matches = matches.where(priority: params[:priority].to_i) if params[:priority].present? && PRIORITIES.include?(params[:priority].to_i)
    matches.to_a
  end
end
