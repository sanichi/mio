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
  scope :transitive,   -> { where("category ILIKE '%verb%' AND category ~* '(^|[^n])transitive'") } # postgres version 9.2 on tsukuba does not have negative lookbehind, though 9.6 on montauk does
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

  def color_id
    return 0 unless verb?
    return 1 if ichidan?
    return 3 if godan? && iru_eru?
    return 2 if godan?
    return 4 if suru_verb?
    return 5
  end

  def conjugate(tense)
    case tense.to_s
    when "comm" then command
    when "dict" then kanji
    when "masu" then polite
    when "past" then past
    when "pote" then potential
    when "prog" then te + "いる"
    else "invalid tense (#{tense})"
    end
  end

  private

  #
  # Conjugations.
  #

  def command
    if godan?
      godan("e", "command")
    elsif ichidan?
      kanji.sub(/る\z/, "ろ")
    elsif suru_verb?
      unsuru + "しろ"
    elsif kuru?
      "こい"
    elsif suru?
      "しろ"
    else
      kanji + "[not a recognisable type of verb for command form]"
    end
  end

  def past
    if kanji == "行く"
      "行った"
    elsif godan?
      replacement =
        case kanji[-1]
        when "す"            then "した"
        when "く"            then "いた"
        when "ぐ"            then "いだ"
        when "む", "ぶ", "ぬ" then "んだ"
        when "る", "う", "つ" then "った"
        else "[invalid godan verb for plain past]"
        end
      kanji.sub(/.\z/, replacement)
    elsif ichidan?
      kanji.sub(/る\z/, "た")
    elsif suru_verb?
      unsuru + "した"
    elsif kuru?
      "きた"
    elsif suru?
      "した"
    else
      kanji + "[not a recognisable type of verb for te-form]"
    end
  end

  def polite
    if godan?
      godan("i", "polite") + "ます"
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

  def potential
    if godan?
      godan("e", "potential")
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

  def te
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

  #
  # Conjugation helpers.
  #

  def godan(base, form)
    error = "[invalid godan verb for #{form} form]"
    replacement =
      case base
      when "i"
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
        else error
        end
      when "e"
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
        else error
        end
      else
        "[invalid base #{base} for godan verb]"
      end
    kanji.sub(/.\z/, replacement)
  end

  def godan?
    category.match(/\bgodan verb\b/) && reading.match(/[うくぐすつむぶぬる]\z/)
  end

  def ichidan?
    category.match(/\bichidan verb\b/) && iru_eru?
  end

  def iru_eru?
    reading.match(/[いえきけぎげしせじぜちてぢでにねひへびべぴぺみめりれ]る\z/)
  end

  def kuru?
    kanji == "来る"
  end

  def suru?
    reading == "する"
  end

  def suru_verb?
    category.match(/\bsuru verb\b/)
  end

  def unsuru
    kanji.sub(/する\z/, "")
  end

  #
  # Other helpers.
  #

  def truncate
    self.category = category&.truncate(MAX_CATEGORY)
    self.meaning = meaning&.truncate(MAX_MEANING)
  end
end
