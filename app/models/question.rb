class Question < ApplicationRecord
  include Remarkable

  MAX_ANSWER = 100
  MAX_AUDIO = 20
  MAX_QUESTION = 255
  MAX_PIC_SIZE = 1.megabyte
  PIC_TYPES = "jpe?g|gif|png"
  AUD_TYPES = "mp3|ogg|m4a|aiff"

  belongs_to :problem

  has_one_attached :picture, dependent: :purge

  before_validation :normalize_attributes

  validates :question, presence: true, length: { maximum: MAX_QUESTION }
  validates :answer1, :answer2, :answer3, :answer4, length: { maximum: MAX_ANSWER }, allow_nil: true
  validates :solution, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4 }
  validates :audio, length: { maximum: MAX_AUDIO }, format: { with: /\A[-A-Za-z_\d]+\.(#{AUD_TYPES})\z/ }, allow_nil: true
  validate  :must_either_be_answers_or_a_picture
  validate  :check_picture

  default_scope { order(:id) }

  def note_html
    to_html(note)
  end

  def count
    problem.questions.count
  end

  def number
    problem.questions.where("id <= ?", id).count
  end

  def last
    problem.questions.where("id < ?", id).last
  end

  def next
    problem.questions.where("id > ?", id).first
  end

  def audio_path
    return nil unless audio.present?
    "/system/audio/jlpt/n#{5 - problem.level}/#{audio}"
  end

  def audio_type
    return nil unless audio.present?
    "audio/#{audio =~ /\.mp3\z/ ? 'mpeg' : (audio =~ /\.m4a\z/ ? 'mp4' : (audio =~ /\.ogg\z/ ? 'ogg' : 'aiff'))}"
  end

  def any_answers?
    answer1 || answer2 || answer3 || answer4
  end

  private

  def normalize_attributes
    question&.strip!
    answer1&.strip!
    answer2&.strip!
    answer3&.strip!
    answer4&.strip!
    audio&.squish!
    self.answer1 = nil if answer1.blank?
    self.answer2 = nil if answer2.blank?
    self.answer3 = nil if answer3.blank?
    self.answer4 = nil if answer4.blank?
    self.audio = nil if audio.blank?
    note&.strip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end

  def check_picture
    if picture.attached?
      errors.add(:picture, "invalid content type (#{picture.content_type})") unless picture.content_type =~ /\Aimage\/(#{PIC_TYPES})\z/
      errors.add(:picture, "invalid filename (#{picture.filename})")         unless picture.filename.to_s =~ /\.(#{PIC_TYPES})\z/i
      errors.add(:picture, "too large an image size (#{picture.byte_size})") unless picture.byte_size < MAX_PIC_SIZE
    end
  end

  def must_either_be_answers_or_a_picture
    errors.add(:answer1, "no answers or picture") unless any_answers? || picture.attached?
  end
end
