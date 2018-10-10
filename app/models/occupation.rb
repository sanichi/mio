class Occupation < ApplicationRecord
  include Constrainable
  include Pageable

  ENDINGS = %w/者 手 師 家 官 士 優 人/

  belongs_to :vocab

  before_validation :import

  validates :kanji, length: { maximum: Vocab::MAX_KANJI }, presence: true, uniqueness: true
  validates :meaning, length: { maximum: Vocab::MAX_MEANING }, presence: true
  validates :reading, length: { maximum: Vocab::MAX_READING }, presence: true

  scope :by_kanji,   -> { order(Arel.sql('kanji COLLATE "C"')) }
  scope :by_meaning, -> { order(:meaning, Arel.sql('reading COLLATE "C"')) }
  scope :by_reading, -> { order(Arel.sql('reading COLLATE "C"'), :meaning) }
  scope :by_ending,  -> { order(Arel.sql('substring(kanji from \'.$\') COLLATE "C" DESC'), Arel.sql('reading COLLATE "C"')) }

  def self.search(params, path, opt={})
    matches =
    case params[:order]
    when "meaning"
      by_meaning
    when "kanji"
      by_kanji
    when "ending"
      by_ending
    else
      by_reading
    end
    if ENDINGS.include?(params[:ending])
      matches = matches.where("kanji LIKE '%#{params[:ending]}'")
    elsif params[:ending] == "other"
      matches = matches.where(ENDINGS.map{|k| "kanji NOT LIKE '%#{k}'"}.join(" AND "))
    end
    if sql = cross_constraint(params[:q], %w{kanji meaning reading})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def self.homonym_search(params, path, opt={})
    homonyms = Vocab.group(:reading).having('count(*) > 1').pluck(:reading)
    matches = Vocab.where(reading: homonyms)
    matches = matches.by_reading
    if sql = cross_constraint(params[:q], %w{kanji meaning reading})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  private

  def import
    if vocab = Vocab.find_by(kanji: kanji)
      self.kanji = vocab.kanji
      self.meaning = vocab.meaning
      self.reading = vocab.reading
      self.vocab_id = vocab.id
    end
  end
end
