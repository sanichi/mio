class Question < ApplicationRecord
  include Constrainable
  include Remarkable

  MAX_ANSWER = 100
  MAX_AUDIO = 20
  MAX_QUESTION = 255
  MAX_PIC_SIZE = 1.megabyte
  PIC_TYPES = "jpe?g|gif|png"

  belongs_to :problem

  has_one_attached :picture, dependent: :purge

  before_validation :normalize_attributes

  validates :question, length: { minimum: 1, maximum: MAX_QUESTION }, allow_nil: true
  validates :answer1, :answer2, :answer3, :answer4, length: { minimum: 1, maximum: MAX_ANSWER }, allow_nil: true
  validates :solution, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4 }
  validates :audio, length: { maximum: MAX_AUDIO }, format: { with: /\A[-A-Za-z_\d]+\.(mp3|m4a)\z/ }, allow_nil: true
  validate  :must_either_be_a_question_or_an_audio
  validate  :check_picture
  validate  :check_audio

  default_scope { order(:id) }

  # Non-standard - returns a ProblemQuestion data object.
  def self.search(text)
    pq = ProblemQuestion.new
    matches = all
    if sql = cross_constraint(text, [:note])
      matches = matches.where(sql)
    end
    if matches.count == count
      # return an abbreviated form (to save long parameters) when all match
      matches.to_a.each { |question| pq.add(question.problem_id) }
    else
      # populate with full data (possibly leading to long parameter values)
      matches.to_a.each { |question| pq.add(question.problem_id, question.id) }
    end
    pq
  end

  def note_html
    to_html(note)
  end

  def count(qids)
    qids&.size || problem.questions.count
  end

  def number(qids)
    qids ||= problem.questions.map(&:id)
    qids.index(id).to_i + 1
  end

  def last(qids)
    qids ||= problem.questions.map(&:id)
    indx = qids.index(id)
    indx && indx > 0 ? qids[indx - 1] : nil
  end

  def next(qids)
    qids ||= problem.questions.map(&:id)
    indx = qids.index(id)
    indx && indx < qids.size - 1 ? qids[indx + 1] : nil
  end

  def audio_path(abs: false)
    return nil unless audio.present?
    path = "system/audio/jlpt/n#{1 + problem.level}/#{audio}"
    abs ? (Rails.root + "public" + path).to_s : "/#{path}"
  end

  def audio_type
    return nil unless audio.present?
    "audio/#{audio =~ /\.mp3\z/ ? 'mpeg' : 'mp4'}"
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
    self.question = nil if question.blank?
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

  def check_audio
    if audio.present?
      errors.add(:audio, "file does not exist") unless File.file?(audio_path(abs: true))
    end
  end

  def must_either_be_a_question_or_an_audio
    errors.add(:question, "no question or audio") unless question.present? || audio.present?
  end
end