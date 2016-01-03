class Favourite < ActiveRecord::Base
  include Constrainable
  include Pageable

  MAX_FANS = 50
  MAX_LINK = 100
  MAX_NAME = 50
  MIN_YEAR = 1900

  before_validation :normalize_attributes

  validates :category, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than: I18n.t("favourite.categories").size }
  validates :fans, format: { with: /\A[A-Z][a-z]+(, [A-Z][a-z]+)*\z/ }, length: { maximum: MAX_FANS }
  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { scope: :category }
  validates :year, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YEAR, less_than_or_equal_to: Date.today.year }
  validates :link, format: { with: /\Ahttps?:\/\/[^\s]+\z/ }, length: { maximum: MAX_LINK }, allow_nil: true

  scope :by_year, -> { order(year: :desc) }

  def self.search(params, path)
    matches = by_year
    matches = matches.where(category: params[:category].to_i) if params[:category].present?
    matches = matches.where("fans LIKE ?", "%#{params[:fan]}%") if params[:fan].present?
    constraint = numerical_constraint(params[:year], :year)
    matches = matches.where(constraint) if constraint
    paginate(matches, params, path)
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
    self.fans = fans.to_s.scan(/[a-z]+/i).map(&:capitalize).uniq.sort.join(", ")
    self.link.squish!
    self.link = nil unless link.present?
    self.name.squish!
  end
end
