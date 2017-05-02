class Vocab < ApplicationRecord
  include Pageable

  MAX_AUDIO = 50
  MAX_KANA = 20
  MAX_KANJI = 20
  MAX_MEANING = 100

  before_validation :truncate

  validates :audio, presence: true, length: { maximum: MAX_AUDIO }, format: { with: /\A[a-f0-9]+\.(mp3|ogg)\z/ }, uniqueness: true
  validates :kana, presence: true, length: { maximum: MAX_KANA }
  validates :kanji, presence: true, length: { maximum: MAX_KANJI }, uniqueness: true
  validates :level, presence: true, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: 60 }
  validates :meaning, presence: true, length: { maximum: MAX_MEANING }
  validates :kanji_correct, :kanji_incorrect, :meaning_correct, :meaning_incorrect, numericality: { integer_only: true, greater_than_or_equal_to: 0 }

  scope :by_kana,    -> { order(:kana, :meaning) }
  scope :by_meaning, -> { order(:meaning, :kana) }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "meaning" then by_meaning
    else                by_kana
    end
    paginate(matches, params, path, opt)
  end

  def audio_type
    "audio/#{audio =~ /\.mp3\z/ ? 'mpeg' : 'ogg'}"
  end

  private

  def truncate
    self.meaning = meaning&.truncate(MAX_MEANING)
  end
end
