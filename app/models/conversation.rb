class Conversation < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_AUDIO = 50
  MAX_TITLE = 150

  before_validation :normalize_attributes

  validates :audio, presence: true, length: { maximum: MAX_AUDIO }, format: { with: /\A[-A-Za-z_\d]+\.(mp3|ogg|m4a)\z/ }, uniqueness: true
  validates :story, presence: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }

  scope :by_id, -> { order(:id) }

  def self.search(params, path, opt={})
    matches = by_id
    if sql = cross_constraint(params[:q], %w{title story})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def short_story
    story.truncate(15)
  end

  def short_title
    title.truncate(15)
  end

  def story_html
    to_html(story)
  end

  def audio_exist?
    Rails.root.join("public", "system", "audio", "conversations", audio).exist?
  end

  def audio_path
    "/system/audio/conversations/#{audio}"
  end

  def audio_type
    "audio/#{audio =~ /\.mp3\z/ ? 'mpeg' : (audio =~ /\.m4a\z/ ? 'mp4' : 'ogg')}"
  end

  private

  def normalize_attributes
    title.squish!
    audio.squish!
    story.lstrip!
    story.rstrip!
    story.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end
end
