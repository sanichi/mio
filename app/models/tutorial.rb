class Tutorial < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable
  include Splitable

  MAX_SUMMARY = 100

  before_validation :normalize_attributes

  validates :summary, presence: true, length: { maximum: MAX_SUMMARY }
  validates :date, date: { before_or_equal: Proc.new { Date.today } }, uniqueness: true

  scope :by_date,    -> { order(:date) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, no_drafts, opt={})
    matches = by_date
    if sql = cross_constraint(params[:q], %w{summary notes})
      matches = matches.where(sql)
    end
    matches = matches.where(draft: false) if no_drafts
    paginate(matches, params, path, opt)
  end

  def number
    self.class.where("date < ?", date).count + 1
  end

  def split_notes
    html = split(notes)
    html.unshift "<p>Summary: #{summary}".html_safe
    html
  end

  private

  def normalize_attributes
    summary&.squish!
    notes&.lstrip!
    notes&.rstrip!
    notes&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    self.notes = nil unless notes.present?
  end
end
