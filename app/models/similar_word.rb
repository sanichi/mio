class SimilarWord < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_READINGS = 100
  SEPARATOR = I18n.t("symbol.katakana_middle_dot")

  before_validation :canonicalize

  validates :readings, length: { maximum: MAX_READINGS }, format: { with: /\A\S+( \S+)+\z/ }, uniqueness: true

  scope :by_readings, -> { order(Arel.sql('readings COLLATE "C"')) }

  def self.search(params, path, opt={})
    matches = by_readings
    if sql = cross_constraint(params[:q], %w{readings})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def display(alt=nil)
    (alt || readings).gsub(" ", SEPARATOR)
  end

  def kanji_display
    Vocab.by_reading.where(reading: readings.split).pluck(:kanji).join(SEPARATOR)
  end

  private

  def canonicalize
    self.readings = readings.squish.split.sort.join(" ") unless readings.nil?
  end
end
