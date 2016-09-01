class Tapa < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_KEYWORDS = 100
  MAX_TITLE = 50
  URL = "https://www.rubytapas.com/"
  MAX_POST_ID = 150

  before_validation :canonicalize

  validates :keywords, length: { maximum: MAX_KEYWORDS }, allow_nil: true
  validates :number, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true
  validates :post_id, format: { with: /\A20\d\d\/\d\d\/\d\d\/episode-\d+-[^\/\s]+\/\z/ }, length: { maximum: MAX_POST_ID }, uniqueness: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }

  scope :by_number,  -> { order(number: :desc) }

  def self.search(params, path, opt={})
    matches = by_number
    if sql = numerical_constraint(params[:number], :number)
      matches = matches.where(sql)
    end
    if (q = params[:query]).present?
      matches = matches.where("(title ILIKE ? OR keywords ILIKE ? OR notes ILIKE ?)", "%#{q}%", "%#{q}%", "%#{q}%")
    end
    case params[:other]
    when "star"  then matches = matches.where(star: true)
    when "notes" then matches = matches.where.not(notes: nil)
    end
    paginate(matches, params, path, opt)
  end

  def post_url
    URL + post_id
  end

  def notes_html
    to_html(notes)
  end

  private

  def canonicalize
    title&.squish!
    if post_id.present?
      post_id.strip!
      post_id.sub!(URL, "")
      post_id.sub!(/\A\/+/, "")
      self.post_id = post_id + "/" unless post_id.match(/\/\z/)
    end
    keywords&.squish!
    keywords&.sub!(/\A\s*,/, "")
    keywords&.sub!(/,\s*\z/, "")
    keywords&.gsub!(/\s*,\s*/, ", ")
    self.keywords = nil unless keywords.present?
    self.notes = nil if notes.blank?
  end
end
