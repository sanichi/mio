class Tutorial < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_SUMMARY = 100
  FEN1 = /\n*\s*(FEN\s*"[^"]*")\s*\n*/
  FEN2 = /\AFEN\s*"([^"]*)"\z/

  before_validation :normalize_attributes

  validates :summary, presence: true, length: { maximum: MAX_SUMMARY }
  validates :date, date: { before_or_equal: Proc.new { Date.today } }, uniqueness: true

  scope :by_date,    -> { order(:date) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches = by_date
    if sql = cross_constraint(params[:q], %w{summary})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def number
    self.class.where("date < ?", date).count + 1
  end

  def note_blocks
    blocks = notes.present? ? notes.split(FEN1) : []
    blocks.map! do |b|
      if b.present?
        if b.match(FEN2)
          "<p>#{$1}</p>".html_safe
        else
          to_html(b)
        end
      else
        nil
      end
    end.compact!
    blocks.unshift(to_html(I18n.t("tutorial.summary") + ": " + summary))
    blocks
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
