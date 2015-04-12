class Comment < ActiveRecord::Base
  MAX_TEXT, MAX_SOURCE = 140, 30

  belongs_to :commentable, polymorphic: true

  default_scope { order(date: :desc, updated_at: :desc) }

  validates :date, presence: true
  validates :source, presence: true, length: { maximum: MAX_SOURCE }
  validates :text, presence: true, length: { maximum: MAX_TEXT }
end
