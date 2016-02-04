class Tapa < ActiveRecord::Base
  include Pageable

  MAX_TITLE = 50
  MAX_KEYWORDS = 100

  before_validation :canonicalize

  validates :keywords, presence: true, length: { maximum: MAX_KEYWORDS }
  validates :number, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }

  scope :by_number,  -> { order(:number) }

  def self.search(params, path, opt={})
    matches = by_number
    matches = matches.where(number: params[:number].to_i) if params[:number]&.match(/\A[1-9]\d*\z/)
    if params[:query].present?
      q = params[:query].squish
      matches = matches.where("(title ILIKE ? OR keywords ILIKE ?)", "%#{q}%", "%#{q}%")
    end
    paginate(matches, params, path, opt)
  end

  private

  def canonicalize
    title&.squish!
    keywords&.squish!
    keywords&.sub!(/\A\s*,/, "")
    keywords&.sub!(/,\s*\z/, "")
    keywords&.gsub!(/\s*,\s*/, ", ")
  end
end
