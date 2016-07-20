class Favourite < ApplicationRecord
  include Constrainable

  MAX_LINK = 100
  MAX_NAME = 50
  MIN_YEAR = 1900
  MAX_FANS = 50 # legacy

  before_validation :normalize_attributes, :at_least_one_vote

  validates :category, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than: I18n.t("favourite.categories").size }
  validates :link, format: { with: /\Ahttps?:\/\/[^\s]+\z/ }, length: { maximum: MAX_LINK }, allow_nil: true
  validates :mark, :sandra, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than:  I18n.t("favourite.votes").size }
  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { scope: :category }
  validates :year, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YEAR, less_than_or_equal_to: Date.today.year }

  scope :by_year, -> { order(year: :desc, name: :asc) }

  def self.search(params)
    matches = by_year
    matches = matches.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    matches = matches.where(category: params[:category].to_i) if params[:category].present?
    matches = matches.where("mark > 0") if params[:fan] == "m"
    matches = matches.where("sandra > 0") if params[:fan] == "s"
    constraint = numerical_constraint(params[:year], :year)
    matches = matches.where(constraint) if constraint
    matches.all
  end

  def update_people(ids)
    return unless ids.respond_to?(:map)
    new_ids = ids.map(&:to_i).uniq.select{ |id| id > 0 }.sort
    old_ids = people.map(&:id).sort
    return if old_ids == new_ids
    self.people = new_ids.map{ |id| Person.find_by(id: id) }.compact
  end

  private

  def normalize_attributes
    self.link.squish!
    self.link = nil unless link.present?
    self.name.squish!
  end

  def at_least_one_vote
    %i/mark sandra/.each { |v| errors.add(v, "need at least one vote") } if mark + sandra == 0
  end
end
