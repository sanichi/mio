class VocabQuestion < ApplicationRecord
  belongs_to :vocab
  belongs_to :vocab_test

  before_validation :truncate, :cleanup
  before_create :check_answer
  after_create :update_test

  validates :vocab_id, :vocab_test_id, numericality: { integer_only: true, greater_than: 0 }
  validates :kanji, length: { maximum: Vocab::MAX_KANJI }, allow_nil: true
  validates :meaning, length: { maximum: Vocab::MAX_MEANING }, allow_nil: true
  validates :reading, length: { maximum: Vocab::MAX_READING }, allow_nil: true

  default_scope { order(id: :desc) }

  def answered_correctly?
    kanji_correct && meaning_correct && reading_correct
  end

  def blanks?
    case vocab_test.category
    when "a2km"
      kanji.blank? || meaning.blank?
    when "k2mr"
      meaning.blank? || reading.blank?
    when "m2k"
      kanji.blank?
    else
      false
    end
  end

  def meaning_plus
    return meaning unless meaning_correct
    "#{meaning} (#{vocab&.meaning})"
  end

  private

  def truncate
    self.kanji = kanji&.truncate(Vocab::MAX_KANJI)
    self.meaning = meaning&.truncate(Vocab::MAX_MEANING)
    self.reading = reading&.truncate(Vocab::MAX_READING)
  end

  def cleanup
    # for some reason, backspaces can sometimes corrupt the input
    self.kanji = kanji&.gsub(/\x08/, "")
    self.meaning = meaning&.gsub(/\x08/, "")
    self.reading = reading&.gsub(/\x08/, "")
  end

  def check_answer
    return unless vocab.present? && vocab_test.present?
    self.kanji_correct   = true if !vocab_test.kanji_required?   || vocab.test_kanji(kanji)
    self.meaning_correct = true if !vocab_test.meaning_required? || vocab.test_meaning(meaning)
    self.reading_correct = true if !vocab_test.reading_required? || vocab.test_reading(reading)
  end

  def update_test
    vocab_test.update_stats
  end
end
