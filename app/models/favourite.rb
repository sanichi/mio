class Favourite < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_LINK = 200
  MAX_NAME = 50
  MAX_NOTE = 200
  MIN_YEAR = 1900
  MAX_SCORE = 10
  MIN_SCORE = 0

  before_validation :normalize_attributes

  validates :category, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than: I18n.t("favourite.categories").size }
  validates :link, format: { with: /\Ahttps?:\/\/[^\s]+\z/ }, length: { maximum: MAX_LINK }, allow_nil: true
  validates :mark, :sandra, numericality: { integer_only: true, greater_than_or_equal_to: MIN_SCORE, less_than_or_equal_to: MAX_SCORE }
  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { scope: :category }
  validates :note, presence: true
  validates :year, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YEAR, less_than_or_equal_to: Date.today.year }
  validate :at_least_one_vote

  scope :by_year,     -> { order(year: :desc, name: :asc) }
  scope :by_mark,     -> { order(mark: :desc, name: :asc) }
  scope :by_sandra,   -> { order(sandra: :desc, name: :asc) }
  scope :by_combo,    -> { order(Arel.sql("(sandra + mark) DESC, name ASC")) }
  scope :by_entered,  -> { order(created_at: :desc) }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "mark"
      by_mark
    when "sandra"
      by_sandra
    when "year"
      by_year
    when "entered"
      by_entered
    else
      by_combo
    end
    if params[:category].present?
      matches = matches.where(category: params[:category].to_i)
    end
    if sql = cross_constraint(params[:query], %w{name note})
      matches = matches.where(sql)
    end
    if sql = numerical_constraint(params[:year], :year)
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def total
    mark + sandra
  end

  private

  def normalize_attributes
    self.link&.squish!
    self.link = nil unless link.present?
    self.name&.squish!
    self.name = name&.truncate(MAX_NAME)
    self.note&.squish!
    self.note = note&.truncate(MAX_NOTE)
  end

  def at_least_one_vote
    if mark.present? && sandra.present? && mark + sandra == 0
      %i/mark sandra/.each { |v| errors.add(v, "need at least one score") }
    end
  end
end
