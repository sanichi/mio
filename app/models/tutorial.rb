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
    if sql = cross_constraint(params[:q], %w{summary notes})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def number
    self.class.where("date < ?", date).count + 1
  end

  def split_notes
    html = []
    fens = []
    fen_id = 0
    parts = notes.present? ? notes.split(FEN1) : []
    parts.each do |p|
      if p.present?
        if p.match(FEN2)
          html.push "FEN__#{fen_id}"
          fen_id += 1
          fens.push $1
        else
          html.push to_html(p)
        end
      end
    end
    html.unshift "<p>Summary: #{summary}".html_safe
    [html, fens]
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
