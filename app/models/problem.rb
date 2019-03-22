class Problem < ApplicationRecord
  include Pageable
  include Remarkable

  MAX_LEVEL = I18n.t("problem.levels").size - 1
  MAX_CATEGORY = I18n.t("problem.categories").size - 1
  MAX_SUBCATEGORY = I18n.t("problem.subcategories").size - 1

  has_many :questions, dependent: :destroy

  before_validation :normalize_attributes

  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_LEVEL }
  validates :category, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_CATEGORY }
  validates :subcategory, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_SUBCATEGORY }, uniqueness: { scope: [:level, :category] }
  validates :note, presence: true

  scope :natural_order, -> { order(:level, :category, :subcategory) }

  def self.search(params, path, opt={})
    matches = natural_order
    matches = filter(matches, params, :level, MAX_LEVEL)
    matches = filter(matches, params, :category, MAX_CATEGORY)
    matches = filter(matches, params, :subcategory, MAX_SUBCATEGORY)
    paginate(matches, params, path, opt)
  end

  def note_html
    to_html(note)
  end

  def description(locale="jp")
    lev = I18n.t("problem.levels", locale: "en")[level]
    cat = I18n.t("problem.categories", locale: locale)[category]
    sub = I18n.t("problem.subcategories", locale: locale)[subcategory]
    ("%s %s [%s]" % [lev, cat, sub]).html_safe
  end

  private

  def normalize_attributes
    note&.lstrip!
    note&.rstrip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end

  class << self

    private

    def filter(matches, params, param, max)
      return matches unless params[param]&.match(/\A(0|[1-9]\d*)\z/)
      value = params[param].to_i
      return matches if value > max
      matches.where(param => value)
    end
  end
end
