class KanjiQuestion < ApplicationRecord
  belongs_to :kanji
  belongs_to :kanji_test

  after_create :update_test

  validates :kanji_id, :kanji_test_id, numericality: { integer_only: true, greater_than: 0 }

  default_scope { order(id: :desc) }

  private

  def update_test
    kanji_test.update_stats
  end
end
