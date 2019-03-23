class Question < ApplicationRecord
  include Remarkable

  MAX_QUESTION = 255
  MAX_ANSWER = 100

  belongs_to :problem

  before_validation :normalize_attributes

  validates :question, presence: true, length: { maximum: MAX_QUESTION }
  validates :answer1, :answer2, :answer3, presence: true, length: { maximum: MAX_ANSWER }
  validates :solution, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4 }
  validate  :solution_cant_be_4_if_optional_answer4_is_blank

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

  def url_for_problem
    ActionDispatch::Routing::UrlFor.url_for(controller: "problems", action: "show", id: problem.id, question_id: id, only_path: true)
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
end
