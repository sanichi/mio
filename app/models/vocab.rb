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
  IE = "いえきけぎげしせじぜちてぢでにねひへびべぴぺみめりれ"

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
  scope :by_reading,   -> { order('reading COLLATE "C"', :level) }
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

  def self.verb_search(params, path, opt={})
    matches = where("category ~* '(^|[^d])verb'")
    matches = case params[:order]
    when "meaning" then matches.by_meaning
    when "level"   then matches.by_level
    else                matches.by_reading
    end
    if sql = cross_constraint(params[:q], %w{kanji meaning reading})
      matches = matches.where(sql)
    end
    if (level = params[:level].to_i) > 0
      matches = matches.where(level: level)
    end
    if %w/godan ichidan suru/.include?(type = params[:type])
      matches = matches.where("category ILIKE '%#{type}%'")
    end
    if params[:type] == "goichidan"
      matches = matches.where("category ILIKE '%godan%' AND reading ~* '[#{IE}]る$'")
    end
    matches = case params[:trans]
    when "transitive"   then matches.where("category ~* '(^|[^n])transitive' AND category NOT ILIKE '%intransitive%'")
    when "intransitive" then matches.where("category !~* '(^|[^n])transitive' AND category ILIKE '%intransitive%'")
    when "both"         then matches.where("category ~* '(^|[^n])transitive' AND category ILIKE '%intransitive%'")
    when "neither"      then matches.where("category NOT ILIKE '%transitive%' AND category NOT ILIKE '%suru%'")
    else matches
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
    when "pass" then passive
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
      godan(:e)
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

  def passive
    if godan?
      godan(:a) + "れる"
    elsif ichidan?
      kanji.sub(/る\z/, "られる")
    elsif suru_verb?
      unsuru + "される"
    elsif kuru?
      "こられる"
    elsif suru?
      "される"
    else
      kanji + "[not a recognisable type of verb for passive form]"
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
      godan(:i) + "ます"
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
      godan(:e) + "る"
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

  def godan(base)
    return "[invalid base #{base} for godan verb]" unless %i/a i e/.include?(base)
    replacement =
      case kanji[-1]
      when "う"
        case base
        when :a then "わ"
        when :e then "え"
        when :i then "い"
        end
      when "く"
        case base
        when :a then "か"
        when :e then "け"
        when :i then "き"
        end
      when "ぐ"
        case base
        when :a then "が"
        when :e then "げ"
        when :i then "ぎ"
        end
      when "す"
        case base
        when :a then "さ"
        when :e then "せ"
        when :i then "し"
        end
      when "つ"
        case base
        when :a then "た"
        when :e then "て"
        when :i then "ち"
        end
      when "ぬ"
        case base
        when :a then "ま"
        when :e then "ね"
        when :i then "に"
        end
      when "ぶ"
        case base
        when :a then "ば"
        when :e then "べ"
        when :i then "び"
        end
      when "む"
        case base
        when :a then "ま"
        when :e then "め"
        when :i then "み"
        end
      when "る"
        case base
        when :a then "ら"
        when :e then "れ"
        when :i then "り"
        end
      else "[invalid base #{base} for godan verb]"
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
    reading.match(/[#{IE}]る\z/)
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
