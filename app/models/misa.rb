class Misa < ApplicationRecord
  include Constrainable
  include Linkable
  include Pageable
  include Remarkable

  CATEGORIES = %w/none beginners counters dajare difference grammar howto miku mistakes native proverbs satori shadowing puroyobi vocab yuta tofugu dogen smile/
  MAX_CATEGORY = 10
  MAX_MINUTES = 6
  MAX_NUMBER = 32767
  MAX_SERIES = 16
  MAX_TITLE = 150
  MAX_URL = 256

  before_validation :normalize_attributes
  after_save :count_lines

  validates :minutes, format: { with: /\A\d{1,3}:[0-5]\d\z/ }
  validates :url, format: { with: /\Ahttps?:\/\/.+/ }, length: { maximum: MAX_URL }, uniqueness: true
  validates :alt, format: { with: /\Ahttps?:\/\/.+/ }, length: { maximum: MAX_URL }, uniqueness: true, allow_nil: true
  validates :published, date: { before_or_equal: Proc.new { Date.today } }
  validates :title, presence: true, length: { maximum: MAX_TITLE }, uniqueness: true
  validates :number, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_NUMBER }, uniqueness: { scope: :series }, allow_nil: true
  validates :series, presence: true, length: { maximum: MAX_SERIES }, allow_nil: true

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "created"
      order(:id)
    when "published"
      order(:published)
    else
      order(updated_at: :desc)
    end
    matches = matches.where(series: params[:series]) if params[:series].present?
    if sql = cross_constraint(params[:q], %w{title note})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def note_html
    to_html(link_vocabs(note))
  end

  def series_number
    return "" unless series
    text = ["#{series} #{number}"]
    sorted = Misa.where(series: series).order(:number)
    index = sorted.index { |n| n.id == id }
    if index
      prv = sorted[index - 1] if index > 0
      nxt = sorted[index + 1] if index < sorted.size - 1
      if prv
        text.unshift(%Q{<a href="/misas/#{prv.id}">#{I18n.t("misa.prev")}</a>})
      end
      if nxt
        text.push(%Q{<a href="/misas/#{nxt.id}">#{I18n.t("misa.next")}</a>})
      end
    end
    text.join(" ").html_safe
  end

  private

  def normalize_attributes
    title&.squish!
    url&.squish!
    note&.lstrip!
    note&.rstrip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    self.minutes = "#{$1}:00" if minutes.match(/\A(\d{1,3})(:0?)?\z/)
    self.alt = nil if alt.blank?
    series&.squish!
    if series.blank?
      self.series = nil
      self.number = nil
    else
      if number.blank? || number < 1
        self.number = Misa.where(series: series).maximum(:number).to_i + 1
      end
    end
  end

  def count_lines
    count = note ? note.split("\n").size : 0
    update_column(:lines, count) unless lines == count
  end
end
