class Book < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  CATEGORIES = %w{opening ending middle tournament match game biography puzzle training other}
  MAX_AUTHOR = 60
  MAX_BORROWER = 30
  MAX_CATEGORY = 10
  MAX_MEDIUM = 10
  MAX_TITLE = 100
  MEDIA = %w{book cd}
  MIN_YEAR = 1800

  before_validation :normalize_attributes

  validates :author, length: { maximum: MAX_AUTHOR }, presence: true
  validates :borrower, length: { maximum: MAX_BORROWER }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :medium, inclusion: { in: MEDIA }
  validates :title, presence: true, length: { maximum: MAX_TITLE }, uniqueness: { scope: :author }
  validates :year, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YEAR, less_than_or_equal_to: Date.today.year }

  scope :by_author, -> { order(:author, :year, :title) }
  scope :by_title,  -> { order(:title, :year, :author) }
  scope :by_year,   -> { order(year: :desc, title: :asc, author: :asc) }

  def self.search(params, path, opt={})
    matches = case params[:order]
      when "author" then by_author
      when "title"  then by_title
      else               by_year
    end
    sql = nil
    matches = matches.where(sql) if sql = cross_constraint(params[:title], [:title])
    matches = matches.where(sql) if sql = cross_constraint(params[:author], [:author])
    if params[:borrower]&.match?(/\A\s*ALL\s*\z/)
      matches = matches.where.not(borrower: nil)
    else
      matches = matches.where(sql) if sql = cross_constraint(params[:borrower], [:borrower])
    end
    matches = matches.where(sql) if sql = numerical_constraint(params[:year], :year)
    matches = matches.where(medium: params[:medium]) if params[:medium].present?
    matches = matches.where(category: params[:category]) if params[:category].present?
    paginate(matches, params, path, opt)
  end

  def note_html
    to_html(note)
  end

  private

  def normalize_attributes
    title&.squish!
    author&.squish!
    borrower&.squish!
    self.borrower = nil unless borrower.present?
    note&.lstrip!
    note&.rstrip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    self.note = nil unless note.present?
  end
end
