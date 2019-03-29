class Question < ApplicationRecord
  include Remarkable

  MAX_ANSWER = 100
  MAX_QUESTION = 255
  MAX_PIC_SIZE = 1.megabyte
  PIC_TYPES = "jpe?g|gif|png"


  belongs_to :problem

  has_one_attached :picture, dependent: :purge

  before_validation :normalize_attributes

  validates :question, presence: true, length: { maximum: MAX_QUESTION }
  validates :answer1, :answer2, :answer3, presence: true, length: { maximum: MAX_ANSWER }
  validates :solution, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4 }
  validate  :solution_cant_be_4_if_optional_answer4_is_blank
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

  private

  def normalize_attributes
    question&.strip!
    answer1&.strip!
    answer2&.strip!
    answer3&.strip!
    answer4&.strip!
    note&.strip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end

  def solution_cant_be_4_if_optional_answer4_is_blank
    if solution == 4 && answer4.blank?
      errors.add(:solution, "solution corresponds to blank answer 4")
    end
  end

  def check_picture
    if picture.attached?
      errors.add(:picture, "invalid content type (#{picture.content_type})") unless picture.content_type =~ /\Aimage\/(#{PIC_TYPES})\z/
      errors.add(:picture, "invalid filename (#{picture.filename})")         unless picture.filename.to_s =~ /\.(#{PIC_TYPES})\z/i
      errors.add(:picture, "too large an image size (#{picture.byte_size})") unless picture.byte_size < MAX_PIC_SIZE
    end
  end
end
