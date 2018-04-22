class Misa < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  CATEGORIES = %w/none beginners grammar difference native howto dajare/
  MAX_CATEGORY = 10
  MAX_MINUTES = 6
  MAX_SHORT = 15
  MAX_LONG = 15
  MAX_TITLE = 150

  before_validation :normalize_attributes
  after_save :count_lines

  validates :category, inclusion: { in: CATEGORIES }
  validates :minutes, format: { with: /\A\d{1,3}:[0-5]\d\z/ }
  validates :short, format: { with: /\A\S+\z/ }, length: { maximum: MAX_SHORT }, uniqueness: true, allow_nil: true
  validates :long, format: { with: /\A\S+\z/ }, length: { maximum: MAX_LONG }, uniqueness: true, allow_nil: true
  validates :published, date: { before_or_equal: Proc.new { Date.today } }
  validates :title, presence: true, length: { maximum: MAX_TITLE }, uniqueness: true
  validate :must_have_at_least_one_video

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "created"
      order(:id)
    when "published"
      order(:published)
    else
      order(updated_at: :desc)
    end
    matches = matches.where(category: params[:category]) if CATEGORIES.include?(params[:category])
    if sql = cross_constraint(params[:q], %w{title note})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def note_html
    to_html(note)
  end

  def full_title
    "#{title} (#{I18n.t("misa.categories.#{category}")})"
  end

  def short_url
    "https://www.youtube.com/watch?v=#{short}"
  end

  def long_url
    "https://youtu.be/#{long}"
  end

  def target
    "misa"
  end

  private

  def normalize_attributes
    title.squish!
    note&.lstrip!
    note&.rstrip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    self.short = nil if short.blank?
    self.long = nil if long.blank?
  end

  def count_lines
    count = note ? note.split("\n").size : 0
    update_column(:lines, count) unless lines == count
  end

  def must_have_at_least_one_video
    errors.add(:short, "must have at least one video") unless short.present? || long.present?
  end
end
