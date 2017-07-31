class Vocab < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_AUDIO = 50
  MAX_CATEGORY = 50
  MAX_READING = 20
  MAX_KANJI = 20
  MAX_LEVEL = 60
  MAX_MEANING = 100
  MIN_LEVEL = 1
  TENSES = %w/dict masu pote prog/

  has_many :vocab_questions, dependent: :destroy

  before_validation :truncate

  validates :audio, length: { maximum: MAX_AUDIO }, format: { with: /\A[a-f0-9]+\.(mp3|ogg)\z/ }, uniqueness: true
  validates :category, length: { maximum: MAX_CATEGORY }, presence: true
  validates :kanji, length: { maximum: MAX_KANJI }, presence: true, uniqueness: true
  validates :level, numericality: { integer_only: true, greater_than_or_equal_to: MIN_LEVEL, less_than_or_equal_to: MAX_LEVEL }
  validates :meaning, length: { maximum: MAX_MEANING }, presence: true
  validates :reading, length: { maximum: MAX_READING }, presence: true

  scope :by_kanji,     -> { order('kanji COLLATE "C"') }
  scope :by_level,     -> { order(:level, 'reading COLLATE "C"') }
  scope :by_meaning,   -> { order(:meaning, 'reading COLLATE "C"') }
  scope :by_reading,   -> { order('reading COLLATE "C"', :meaning) }
  scope :transitive,   -> { where("category ILIKE '%verb%' AND category ILIKE '%transitive%' AND category NOT ILIKE '%intransitive%'") }
  scope :intransitive, -> { where("category ILIKE '%verb%' AND category ILIKE '%intransitive%'") }


  def self.search(params, path, opt={})
    matches = case params[:order]
    when "meaning" then by_meaning
    when "level"   then by_level
    else                by_reading
    end
    if sql = cross_constraint(params[:q], %w{category kanji meaning reading})
      matches = matches.where(sql)
    end
    if (level = params[:level].to_i) > 0
      matches = matches.where(level: level)
    end
    paginate(matches, params, path, opt)
  end

  def kanji_reading
    "#{kanji} (#{reading})"
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
    reading.split(/\s*,\s*/).include?(str.to_s)
  end

  def verb?
    category.match(/\bverb\b/)
  end

  def conjugate(tense)
    case tense
    when "dict" then kanji
    when "masu" then polite_form
    when "pote" then potential_form
    when "prog" then te_form + "いる"
    else "invalid tense (#{tense})"
    end
  end

  private

  def truncate
    self.category = category&.truncate(MAX_CATEGORY)
    self.meaning = meaning&.truncate(MAX_MEANING)
  end

  def ichidan?
    category.match(/\bichidan verb\b/) && reading.match(/[いえきけぎげしせじぜちてぢでにねひへびべぴぺみめりれ]る\z/)
  end

  def godan?
    category.match(/\bgodan verb\b/) && reading.match(/[うくぐすつむぶぬる]\z/)
  end

  def suru_verb?
    category.match(/\bsuru verb\b/)
  end

  def kuru?
    kanji == "来る"
  end

  def suru?
    reading == "する"
  end

  def unsuru
    kanji.sub(/する\z/, "")
  end

  def te_form
    if kanji == "行く"
      "行って"
    elsif godan?
      replacement =
        case kanji[-1]
        when "す"            then "して"
        when "く"            then "いて"
        when "ぐ"            then "いで"
        when "む", "ぶ", "ぬ" then "んで"
        when "る", "う", "つ" then "って"
        else "[invalid godan verb for te-form]"
        end
      kanji.sub(/.\z/, replacement)
    elsif ichidan?
      kanji.sub(/る\z/, "て")
    elsif suru_verb?
      unsuru + "して"
    elsif kuru?
      "きて"
    elsif suru?
      "して"
    else
      kanji + "[not a recognisable type of verb for te-form]"
    end
  end

  def potential_form
    if godan?
      replacement =
        case kanji[-1]
        when "う" then "え"
        when "く" then "け"
        when "ぐ" then "げ"
        when "す" then "せ"
        when "つ" then "て"
        when "ぬ" then "ね"
        when "ぶ" then "べ"
        when "む" then "め"
        when "る" then "れ"
        else "[invalid godan verb for potential form]"
        end
      kanji.sub(/.\z/, replacement + "る")
    elsif ichidan?
      kanji.sub(/る\z/, "られる")
    elsif suru_verb?
      unsuru + "できる"
    elsif kuru?
      "こられる"
    elsif suru?
      "出来る"
    else
      kanji + "[not a recognisable type of verb for potential form]"
    end
  end

  def polite_form
    if godan?
      replacement =
        case kanji[-1]
        when "う" then "い"
        when "く" then "き"
        when "ぐ" then "ぎ"
        when "す" then "し"
        when "つ" then "ち"
        when "ぬ" then "に"
        when "ぶ" then "び"
        when "む" then "み"
        when "る" then "り"
        else "[invalid godan verb for polite form]"
        end
      kanji.sub(/.\z/, replacement + "ます")
    elsif ichidan?
      kanji.sub(/る\z/, "ます")
    elsif suru_verb?
      unsuru + "します"
    elsif kuru?
      "きます"
    elsif suru?
      "します"
    else
      kanji + "[not a recognisable type of verb for polite form]"
    end
  end
end
