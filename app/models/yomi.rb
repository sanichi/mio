class Yomi < ApplicationRecord
  MAX_SYMBOL = 1

  belongs_to :kanji
  belongs_to :reading

  after_save :update_counter_caches

  private

  def update_counter_caches
    if on
      kanji.update_column(:onyomi, kanji.onyomi + 1)
      reading.update_column(:onyomi, reading.onyomi + 1)
    else
      kanji.update_column(:kunyomi, kanji.kunyomi + 1)
      reading.update_column(:kunyomi, reading.kunyomi + 1)
    end
  end
end
