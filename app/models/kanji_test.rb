class KanjiTest < ApplicationRecord
  include Pageable

  has_many :kanji_questions, dependent: :destroy

  after_create :set_total

  validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: Vocab::MAX_LEVEL }

  scope :by_hit,      -> { order(hit_rate: :asc, updated_at: :desc) }
  scope :by_level,    -> { order(level: :asc, updated_at: :desc) }
  scope :by_progress, -> { order(progress_rate: :asc, updated_at: :desc) }
  scope :by_updated,  -> { order(updated_at: :desc) }

  def next_question(kanji_id)
    kanji = Kanji.find_by(id: kanji_id) if kanji_id.present?
    unless kanji.present?
      completed = kanji_questions.each_with_object(Hash.new) do |q, h|
        h[q.kanji_id] = true if q.answer
      end
      available = Kanji.where(level: level).all
      kanji = available.reject{ |k| completed[k.id] }.sample
    end
    return unless kanji.present?
    KanjiQuestion.new(kanji: kanji, kanji_test: self)
  end

  def drop_last_question
    last_question = kanji_questions.first
    return unless last_question
    last_question.destroy
    reload
    update_stats
    last_question.kanji.id
  end

  def update_stats
    set_total
    questions = kanji_questions.to_a

    new_attempts = questions.size
    update_attribute(:attempts, new_attempts) unless new_attempts == attempts

    new_correct = questions.keep_if{ |q| q.answer }.size
    update_attribute(:correct, new_correct) unless new_correct == correct

    new_hit_rate = new_attempts == 0 ? 0 : (new_correct * 100.0 / new_attempts).round
    update_attribute(:hit_rate, new_hit_rate) unless new_hit_rate == hit_rate

    new_progress_rate = total == 0 ? 0 : (new_correct * 100.0 / total).round
    update_attribute(:progress_rate, new_progress_rate) unless new_progress_rate == progress_rate
  end

  def updated_date
    updated_at.to_date
  end

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "level"    then by_level
    when "progress" then by_progress
    when "hit"      then by_hit
    else                 by_updated
    end
    matches = matches.where(level: params[:level].to_i) if params[:level].to_i > 0
    paginate(matches, params, path, opt)
  end

  private

  def set_total
    total_count = Kanji.where(level: level).count
    update_column(:total, total_count) unless total == total_count
  end
end
