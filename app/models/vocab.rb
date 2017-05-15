class Vocab < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_AUDIO = 50
  MAX_KANA = 20
  MAX_KANJI = 20
  MAX_LEVEL = 60
  MAX_MEANING = 100

  before_validation :truncate

  validates :audio, length: { maximum: MAX_AUDIO }, format: { with: /\A[a-f0-9]+\.(mp3|ogg)\z/ }, uniqueness: true
  validates :kana, length: { maximum: MAX_KANA }, presence: true
  validates :kanji, length: { maximum: MAX_KANJI }, presence: true, uniqueness: true
  validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
  validates :meaning, length: { maximum: MAX_MEANING }, presence: true
  validates :kanji_correct, :kanji_incorrect, :meaning_correct, :meaning_incorrect, numericality: { integer_only: true, greater_than_or_equal_to: 0 }

  scope :by_kana,    -> { order('kana COLLATE "C"', :meaning) }
  scope :by_meaning, -> { order(:meaning, 'kana COLLATE "C"') }
  scope :by_level,   -> { order(:level, 'kana COLLATE "C"') }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "meaning" then by_meaning
    when "level"   then by_level
    else                by_kana
    end
    if sql = cross_constraint(params[:q], cols: %w{kanji kana meaning})
      matches = matches.where(sql)
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
