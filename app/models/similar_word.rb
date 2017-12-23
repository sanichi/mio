class SimilarWord < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_READINGS = 100
  SEPARATOR = I18n.t("symbol.katakana_middle_dot")

  before_validation :canonicalize

  validates :readings, presence: true, length: { maximum: MAX_READINGS }, uniqueness: true

  scope :by_readings, -> { order('readings COLLATE "C"') }

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

  private

  def canonicalize
    self.readings = readings.squish.split.sort.join(" ") unless readings.nil?
  end
end
