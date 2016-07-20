class Tapa < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_KEYWORDS = 100
  MAX_TITLE = 50
  POST_URL = "https://rubytapas.dpdcart.com/subscriber/post?id=%d"

  before_validation :canonicalize

  validates :keywords, length: { maximum: MAX_KEYWORDS }, allow_nil: true
  validates :number, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true
  validates :post_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }

  scope :by_number,  -> { order(:number) }

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
    POST_URL % post_id.to_i
  end

  def notes_html
    to_html(notes)
  end

  private

  def canonicalize
    title&.squish!
    keywords&.squish!
    keywords&.sub!(/\A\s*,/, "")
    keywords&.sub!(/,\s*\z/, "")
    keywords&.gsub!(/\s*,\s*/, ", ")
    self.keywords = nil unless keywords.present?
    self.notes = nil if notes.blank?
  end
end
