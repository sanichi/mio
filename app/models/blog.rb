class Blog < ActiveRecord::Base
  include Constrainable
  include Remarkable

  MAX_TITLE = 150

  belongs_to :user

  before_validation :normalize_attributes

  validates :story, presence: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }
  validates :user_id, numericality: { integer_only: true, greater_than: 0 }

  scope :ordered, -> { order(created_at: :desc) }

  def self.search(params)
    sql = nil
    matches = ordered
    matches = matches.where(sql) if sql = cross_constraint(params[:q], cols: %w{title story})
    matches
  end

  def story_html(short: false)
    to_html(short ? first_paragraph : story)
  end

  def paragraphs
    story.scan(/\n\n/).length + 1
  end

  def first_paragraph
    story.match(/\A(\S.*?)\n\n/) ? $1 : story
  end

  private

  def normalize_attributes
    title.squish!
    story.lstrip!
    story.rstrip!
    story.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end
end
