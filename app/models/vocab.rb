class Vocab < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_AUDIO = 50
  MAX_CATEGORY = 50
  MAX_READING = 20
  MAX_KANJI = 20
  MAX_LEVEL = 60
  MAX_MEANING = 100
  MAX_KANA = MAX_READING # for original migration as 'kana' has since been 'renamed' to reading

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

  private

  def truncate
    self.meaning = meaning&.truncate(MAX_MEANING)
    self.category = category&.truncate(MAX_CATEGORY)
  end
end
