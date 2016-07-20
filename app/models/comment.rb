class Comment < ApplicationRecord
  include Remarkable

  MAX_SOURCE = 50

  belongs_to :commentable, polymorphic: true

  default_scope { order(date: :desc, updated_at: :desc) }

  validates :date, presence: true
  validates :source, presence: true, length: { maximum: MAX_SOURCE }
  validates :text, presence: true
  
  def html
    to_html(text)
  end
end
