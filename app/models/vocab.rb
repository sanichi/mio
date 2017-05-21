class Vocab < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_AUDIO = 50
  MAX_CATEGORY = 50
  MAX_READING = 20
  MAX_KANJI = 20
  MAX_LEVEL = 60
  MAX_MEANING = 100

  has_many :vocab_questions, dependent: :destroy

  before_validation :truncate

  validates :audio, length: { maximum: MAX_AUDIO }, format: { with: /\A[a-f0-9]+\.(mp3|ogg)\z/ }, uniqueness: true
  validates :category, length: { maximum: MAX_CATEGORY }, presence: true
  validates :kanji, length: { maximum: MAX_KANJI }, presence: true, uniqueness: true
  validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
  validates :meaning, length: { maximum: MAX_MEANING }, presence: true
  validates :reading, length: { maximum: MAX_READING }, presence: true

  scope :by_reading, -> { order('reading COLLATE "C"', :meaning) }
  scope :by_meaning, -> { order(:meaning, 'reading COLLATE "C"') }
  scope :by_level,   -> { order(:level, 'reading COLLATE "C"') }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "meaning" then by_meaning
    when "level"   then by_level
    else                by_reading
    end
    if sql = cross_constraint(params[:q], %w{category kanji meaning reading})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def audio_type
    "audio/#{audio =~ /\.mp3\z/ ? 'mpeg' : 'ogg'}"
  end

  def test_kanji(str)
    str.to_s == kanji
  end

  def test_meaning(str)
    return false unless str.to_s.length > 1
    meaning.downcase.include?(str.to_s.downcase)
  end

  def test_reading(str)
    str.to_s == reading
  end

  private

  def truncate
    self.category = category&.truncate(MAX_CATEGORY)
    self.meaning = meaning&.truncate(MAX_MEANING)
  end
end
