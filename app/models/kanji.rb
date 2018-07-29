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
    if (l = params[:level].to_i) > 0
      matches = matches.where(level: l)
    end
    if sql = cross_constraint(params[:q], %w{symbol meaning readings.kana})
      # Note .uniq seems to work and is used in place of .distinct as the
      # latter runs into postgres problems with DISTINCT and ORDER BY.
      matches = matches.joins(:readings).where(sql).uniq
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

  def check_reading_data(ron, run, rim)
    split_readings(ron, run)
    check_data(rim)
  end

  def readings_change
    raise "data not set up" unless reading_data_setup?
    return nil unless readings_changed?
    oldon = on_yomi_kana.sort.join(",")
    oldun = kun_yomi_kana.sort.join(",")
    oldim = on_yomis.any?{ |y| y.important } ? "onyomi" : "kunyomi"
    newon = @ons.sort.join(",")
    newun = @uns.sort.join(",")
    newim = @imp
    "%s|%s|%s => %s|%s|%s" % [oldon, oldun, oldim, newon, newun, newim]
  end

  def create_readings(test: false, update: false)
    raise "data not set up" unless reading_data_setup?
    if update
      return nil unless readings_changed?
      destroy_old_readings
    end
    create_readings_and_yomis unless test
    return nil
  end

  private

  def truncate
    self.meaning = meaning&.truncate(MAX_MEANING)
  end

  def split_readings(ron, run)
    @ons  = ron.to_s.gsub(/[\sa-zA-Z\/.*]/, "").split(",").keep_if{ |r| r. present? }
    @uns = run.to_s.gsub(/[\sa-zA-Z\/.*]/, "").split(",").keep_if{ |r| r. present? }
  end

  def check_data(rim)
    return "no onyomi or kunyomi" if @ons.empty? && @uns.empty?
    return "invalid value (#{rim}) for importance" unless rim == "onyomi" || rim == "kunyomi"
    message = "important readings are #{rim} but there are none"
    if rim == "onyomi"
      return message if @ons.empty?
    else
      return message if @uns.empty?
    end
    @imp = rim
    return nil
  end

  def reading_data_setup?
    @ons && @uns && @imp
  end

  def create_readings_and_yomis
    @ons.each do |on|
      r = Reading.find_or_create_by!(kana: on)
      y = Yomi.create!(kanji: self, reading: r, on: true, important: @imp == "onyomi")
    end
    @uns.each do |un|
      r = Reading.find_or_create_by!(kana: un)
      y = Yomi.create!(kanji: self, reading: r, on: false, important: @imp == "kunyomi")
    end
  end

  def readings_changed?
    return true unless on_yomi_kana.to_set == @ons.to_set
    return true unless kun_yomi_kana.to_set == @uns.to_set
    return true if @imp == "onyomi" && on_yomis.any?{ |y| !y.important }
    return true if @imp == "kunyomi" && kun_yomis.any?{ |y| !y.important }
    return false
  end

  def destroy_old_readings
    yomis.each{ |y| y.destroy }
  end
end
