class Kanji < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_SYMBOL = 1
  MAX_MEANING = 100

  has_many :yomis, dependent: :destroy
  has_many :readings, through: :yomis

  before_validation :truncate

  validates :symbol, presence: true, length: { maximum: MAX_SYMBOL }, uniqueness: true
  validates :meaning, presence: true, length: { maximum: MAX_MEANING }
  validates :level, numericality: { integer_only: true, greater_than_or_equal_to: Vocab::MIN_LEVEL, less_than_or_equal_to: Vocab::MAX_LEVEL }

  scope :by_onyomi,  -> { order("kanjis.onyomi DESC", Arel.sql('symbol COLLATE "C"')) }
  scope :by_kunyomi, -> { order("kanjis.kunyomi DESC", 'symbol COLLATE "C"') }
  scope :by_symbol,  -> { order(Arel.sql('symbol COLLATE "C"')) }
  scope :by_total,   -> { order("(kanjis.onyomi + kanjis.kunyomi) DESC", Arel.sql('symbol COLLATE "C"')) }

  def total
    onyomi + kunyomi
  end

  def self.search(params, path, opt={})
    params[:q] = params[:qk] if params[:qk].present? # for views/vocabs/_multi_search
    matches = case params[:order]
    when "onyomi"   then by_onyomi
    when "kunyomi"  then by_kunyomi
    else                 by_total
    end
    matches = matches.includes(yomis: :reading)
    if sql = cross_constraint(params[:q], %w{symbol meaning readings.kana})
      # Note .uniq seems to work and is used in place of .distinct as the
      # latter runs into postgres problems with DISTINCT and ORDER BY.
      matches = matches.joins(:readings).where(sql).uniq
    end
    if (l = params[:level].to_i) > 0
      matches = matches.where(level: l)
    end
    paginate(matches, params, path, opt)
  end

  def on_yomis
    yomis.select{ |y| y.on }
  end

  def kun_yomis
    yomis.select{ |y| !y.on }
  end

  def on_yomi_readings
    on_yomis.map{ |y| y.reading }
  end

  def kun_yomi_readings
    kun_yomis.map{ |y| y.reading }
  end

  def on_yomi_kana
    on_yomi_readings.map{ |r| r.kana }
  end

  def kun_yomi_kana
    kun_yomi_readings.map{ |r| r.kana }
  end

  private

  def truncate
    self.meaning = meaning&.truncate(MAX_MEANING)
  end
end
