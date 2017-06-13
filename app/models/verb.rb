class Verb < ApplicationRecord
  include Constrainable
  include Pageable

  belongs_to :vocab

  CATEGORIES = %w/v1 v5k v5g v5s v5t v5n v5b v5m v5r v5u vi/
  MAX_CATEGORY = 3
  MAX_KANJI = 20
  MAX_MEANING = 500
  MAX_READING = 20

  before_validation :truncate
  after_save :link_vocab

  validates :category, inclusion: { in: CATEGORIES }
  validates :kanji, length: { maximum: MAX_KANJI }, presence: true, uniqueness: true
  validates :meaning, length: { maximum: MAX_MEANING }, presence: true
  validates :reading, length: { maximum: MAX_READING }, presence: true
  validates :transitive, inclusion: { in: [true, false] }

  scope :by_kanji,   -> { order('kanji COLLATE "C"', 'reading COLLATE "C"') }
  scope :by_meaning, -> { order(:meaning, 'reading COLLATE "C"') }
  scope :by_reading, -> { order('reading COLLATE "C"', :meaning) }

  def self.search(params, path, opt={})
    matches = case params[:order]
      when "meaning" then by_meaning
      when "reading" then by_reading
      else                by_kanji
    end
    matches = matches.includes(:vocab)
    matches = case params[:transitivity]
      when "yes" then matches.where(transitive: true)
      when "no" then matches.where(transitive: false)
      else matches
    end
    if sql = cross_constraint(params[:q], %w{kanji meaning reading})
      matches = matches.where(sql)
    end
    if CATEGORIES.include?(params[:category])
      matches = matches.where(category: params[:category])
    end
    paginate(matches, params, path, opt)
  end

  def short_meaning
    meaning.truncate(50)
  end

  private

  def truncate
    self.meaning = meaning&.truncate(MAX_MEANING)
  end

  def link_vocab
    match = Vocab.find_by(kanji: kanji)
    if match
      update_column(:vocab_id, match.id) unless vocab_id == match.id
    else
      update_column(:vocab_id, nil) unless vocab_id.nil?
    end
  end
end
