class Misa < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  CATEGORIES = %w/none beginners counters dajare difference dogen howto mistakes native shadowing smile vocab/
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
    cat = I18n.t("misa.categories.#{category}")
    if title.include? cat
      cat = nil
    else
      cat = "(#{cat})"
    end
    links = nil
    if title =~ /^#([1-9]\d*)/ && category != "none"
      sorted_ids = Misa.where(category: category).where("title ~ '^#[1-9]\d*'").to_a.sort_by! do |misa|
        misa.title =~ /^#([1-9]\d*)/ ? $1.to_i : 0
      end.pluck(:id)
      index = sorted_ids.index { |i| i == id }
      if index
        prev_id = sorted_ids[index - 1] if index > 0
        next_id = sorted_ids[index + 1] if index < sorted_ids.size - 1
        prev_link = %Q{<a href="/misas/#{prev_id}">#{I18n.t("misa.prev")}</a>} if prev_id
        next_link = %Q{<a href="/misas/#{next_id}">#{I18n.t("misa.next")}</a>} if next_id
        if prev_link || next_link
          links = [prev_link, next_link].compact.join(" ")
        end
      end
    end
    [links, title, cat].compact.join(" ").html_safe
  end

  def short_url
    "https://www.youtube.com/watch?v=#{short}"
  end

  def long_url
    "https://youtu.be/#{long}"
  end

  private

  def normalize_attributes
    title.squish!
    note&.lstrip!
    note&.rstrip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    self.minutes = "#{$1}:00" if minutes.match(/\A(\d{1,3})(:0?)?\z/)
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
