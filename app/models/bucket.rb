class Bucket < ActiveRecord::Base
  include Remarkable

  MAX_NAME = 50

  before_validation :normalize_attributes, :at_least_one_person_interested

  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :mark, :sandra, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than:  I18n.t("bucket.levels").size }

  scope :by_name, -> { order(:name) }

  def self.search(params)
    matches = by_name
    matches = matches.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    matches = matches.where("mark > 0") if params[:fan] == "m"
    matches = matches.where("sandra > 0") if params[:fan] == "s"
    matches.all
  end

  def notes_html
    to_html(notes)
  end

  private

  def normalize_attributes
    self.name.squish!
    self.notes = nil unless notes.present?
  end

  def at_least_one_person_interested
    %i/mark sandra/.each { |v| errors.add(v, "need at least one person should be interested") } if mark + sandra == 0
  end
end
