class Link < ActiveRecord::Base
  MAX_URL = 256
  MAX_TEXT = 50
  MAX_TARGET = 20

  belongs_to :linkable, polymorphic: true

  default_scope { order(:text) }

  validates :url, presence: true, length: { maximum: MAX_URL }
  validates :target, presence: true, length: { maximum: MAX_TARGET }, format: { with: /\A\w+\z/ }
  validates :text, presence: true, length: { maximum: MAX_TEXT }
end
