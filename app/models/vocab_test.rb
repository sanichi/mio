class VocabTest < ApplicationRecord
  include Pageable

  MAX_CATEGORY = 5
  CATEGORIES = %w(a2km k2mr m2k)

  has_many :vocab_questions, dependent: :destroy

  after_create :set_total

  validates :category, inclusion: { in: CATEGORIES }
  validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: Vocab::MAX_LEVEL }

  scope :by_hit,      -> { order(hit_rate: :asc, updated_at: :desc) }
  scope :by_level,    -> { order(level: :asc, updated_at: :desc) }
  scope :by_progress, -> { order(progress_rate: :asc, updated_at: :desc) }
  scope :by_updated,  -> { order(updated_at: :desc) }

  def next_question
    completed = vocab_questions.each_with_object(Hash.new) do |q, h|
      h[q.vocab_id] = true if q.answered_correctly?
    end
    available = Vocab.where(level: level).all
    vocab = available.reject{ |v| completed[v.id] }.sample
    return unless vocab.present?
    VocabQuestion.new(vocab: vocab, vocab_test: self)
  end

  def update_stats
    set_total
    questions = vocab_questions.to_a

    new_attempts = questions.size
    update_attribute(:attempts, new_attempts) unless new_attempts == attempts

    new_correct = questions.keep_if{ |q| q.answered_correctly? }.size
    update_attribute(:correct, new_correct) unless new_correct == correct

    new_hit_rate = new_attempts == 0 ? 0 : (new_correct * 100.0 / new_attempts).round
    update_attribute(:hit_rate, new_hit_rate) unless new_hit_rate == hit_rate

    new_progress_rate = total == 0 ? 0 : (new_correct * 100.0 / total).round
    update_attribute(:progress_rate, new_progress_rate) unless new_progress_rate == progress_rate
  end

  def kanji_required?
    category != "k2mr"
  end

  def meaning_required?
    category != "m2k"
  end

  def reading_required?
    category == "k2mr"
  end

  def level_skill
    cat = I18n.t("vocab.test.#{category}")
    "#{level}/#{cat}"
  end

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "level"    then by_level
    when "progress" then by_progress
    when "hit"      then by_hit
    else                 by_updated
    end
    matches = matches.where(category: params[:category]) if CATEGORIES.include?(params[:category])
    paginate(matches, params, path, opt)
  end

  private

  def set_total
    total_count = Vocab.where(level: level).count
    update_column(:total, total_count) unless total == total_count
  end
end
