class Yomi < ApplicationRecord
  MAX_SYMBOL = 1

  belongs_to :kanji
  belongs_to :reading

  after_save :increment_counter_caches
  before_destroy :decrement_counter_caches

  private

  def increment_counter_caches
    if on
      kanji.update_column(:onyomi, kanji.onyomi + 1)
      reading.update_column(:onyomi, reading.onyomi + 1)
    else
      kanji.update_column(:kunyomi, kanji.kunyomi + 1)
      reading.update_column(:kunyomi, reading.kunyomi + 1)
    end
  end

  def decrement_counter_caches
    if on
      kanji.update_column(:onyomi, kanji.onyomi - 1) if kanji.onyomi > 0
      reading.update_column(:onyomi, reading.onyomi - 1) if reading.onyomi > 0
    else
      kanji.update_column(:kunyomi, kanji.kunyomi - 1) if kanji.kunyomi > 0
      reading.update_column(:kunyomi, reading.kunyomi - 1) if reading.kunyomi > 0
    end
    reading.destroy if reading.total == 0
  end
end
