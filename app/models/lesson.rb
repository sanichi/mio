class Lesson < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_CHAPTER = 60
  MAX_CHAPTER_NO = 127
  MAX_LINK = 200
  MAX_SECTION = 50
  MAX_SERIES = 50

  before_validation :normalize_attributes

  validates :chapter, presence: true, length: { maximum: MAX_CHAPTER }, uniqueness: { scope: [:section, :series] }
  validates :chapter_no, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_CHAPTER_NO }, uniqueness: { scope: [:section, :series] }
  validates :complete, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :link, presence: true, length: { maximum: MAX_LINK }, format: { with: /\Ahttps?:\/\/\S+\z/ }
  validates :section, presence: true, length: { maximum: MAX_SECTION }
  validates :series, presence: true, length: { maximum: MAX_SERIES }

  scope :by_chapter, -> { order(:series, :section, :chapter_no) }

  def self.search(params, path, opt={})
    matches = by_chapter
    if sql = cross_constraint(params[:q], %w{series section chapter})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def chapter_and_no
    "#{chapter_no} #{chapter}"
  end

  def chapter_and_links
    collection = Lesson.where(series: series).where(section: section).order(:chapter_no)
    prev_lesson = collection.where("chapter_no < ?", chapter_no).pluck(:id)
    next_lesson = collection.where("chapter_no > ?", chapter_no).pluck(:id)
    prev_link = %Q{<a href="/lessons/#{prev_lesson.last}">#{I18n.t("lesson.prev")}</a>} unless prev_lesson.empty?
    next_link = %Q{<a href="/lessons/#{next_lesson.first}">#{I18n.t("lesson.next")}</a>} unless next_lesson.empty?
    links = nil
    if prev_link || next_link
      links = [prev_link, next_link].compact.join(" ")
    end
    [links, chapter_and_no].compact.join(" ").html_safe
  end

  def complete_percent
    "#{complete}#{I18n.t('lesson.abbrev.complete')}"
  end

  def note_html
    to_html(note)
  end

  def target
    "lesson"
  end

  private

  def normalize_attributes
    chapter.squish!
    section.squish!
    series.squish!
    note&.lstrip!
    note&.rstrip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end
end
