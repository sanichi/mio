class Radical < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_SYMBOL = 1
  MAX_MEANING = 100

  belongs_to :kanji

  before_validation :truncate
  before_update :set_old_meaning

  validates :symbol, presence: true, length: { maximum: MAX_SYMBOL }, uniqueness: true
  validates :meaning, presence: true, length: { maximum: MAX_MEANING }
  validates :level, numericality: { integer_only: true, greater_than_or_equal_to: Vocab::MIN_LEVEL, less_than_or_equal_to: Vocab::MAX_LEVEL }

  scope :by_symbol,  -> { order(Arel.sql('symbol COLLATE "C"')) }
  scope :by_meaning, -> { order(:meaning) }
  scope :by_level,   -> { order(:level, :meaning) }

  def self.search(params, path, opt={})
    params[:q] = params[:qx] if params[:qx].present? # for views/radicals/_dropdown_menu
    matches = case params[:order]
    when "symbol" then by_symbol
    when "level"  then by_level
    else               by_meaning
    end
    matches = matches.includes(:kanji)
    if sql = cross_constraint(params[:q], %w{symbol meaning old_meaning})
      matches = matches.where(sql)
    end
    if (l = params[:level].to_i) > 0
      matches = matches.where(level: l)
    end
    if params[:old] == "old"
      matches = matches.where("old_meaning IS NOT NULL")
    end
    paginate(matches, params, path, opt)
  end

  def meaning_with_old
    if old_meaning.present?
      "#{meaning} (#{old_meaning})"
    else
      meaning
    end
  end

  private

  def truncate
    self.meaning = meaning&.truncate(MAX_MEANING)
  end

  def set_old_meaning
    return if old_meaning.present?
    meanings = changes[:meaning]
    return unless meanings
    old, new = meanings
    return unless old.present? && new.present?
    return if old == new
    self.old_meaning = old
  end
end
