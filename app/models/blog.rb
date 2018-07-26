class Blog < ApplicationRecord
  include Constrainable
  include Remarkable

  MAX_TITLE = 150

  belongs_to :user

  before_validation :normalize_attributes

  validates :story, presence: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }
  validates :user_id, numericality: { integer_only: true, greater_than: 0 }

  scope :ordered, -> { order(created_at: :desc) }

  def self.search(params, user)
    sql = nil
    matches = ordered
    unless user.admin?
      if user.guest?
        matches = matches.where(published)
      else
        matches = matches.where(published.or(owner(user.id)))
      end
    end
    matches = matches.where(sql) if sql = cross_constraint(params[:q], %w{title story})
    matches
  end

  def story_html(short: false)
    to_html(short ? first_paragraph : story, images: !short)
  end

  def paragraphs
    story.split(/\n\n/).length
  end

  def first_paragraph
    story.split(/\n\n/).first
  end

  private

  def normalize_attributes
    title.squish!
    story.lstrip!
    story.rstrip!
    story.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end

  class << self
    def owner(id)
      arel_table[:user_id].eq(id)
    end

    def published
      arel_table[:draft].eq(false)
    end
  end

  private_class_method :owner, :published
end
