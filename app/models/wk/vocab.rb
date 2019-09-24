module Wk
  class Vocab < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Remarkable
    include Wanikani

    # pitch accent patterns
    HEIBAN = 0
    ATAMADAKA = 1
    NAKADAKA = 2
    ODAKA = 3

    # special accent_position which means we've looked but can't find out what it should be
    # when accent_position is nil, it means we haven't even tried to find out yet
    UNKNOWN = -1

    IE = "いえきけぎげしせじぜちてぢでにねひへびべぴぺみめりれ"
    MAX_ACCENT_PATTERN = ODAKA
    MAX_CHARACTERS = 24
    MAX_MEANING = 256
    MAX_PARTS = 80
    MAX_READING = 48
    MIN_ACCENT_PATTERN = HEIBAN
    MIN_ACCENT_POSITION = UNKNOWN
    PARTS = {
      "adjective"         => "adj",
      "adverb"            => "adv",
      "counter"           => "cnt",
      "conjunction"       => "con",
      "expression"        => "exp",
      "godan verb"        => "gov",
      "い adjective"      => "iad",
      "ichidan verb"      => "icv",
      "interjection"      => "int",
      "intransitive verb" => "ivb",
      "な adjective"      => "nad",
      "の adjective"      => "noa",
      "numeral"           => "num",
      "noun"              => "nun",
      "proper noun"       => "pno",
      "prefix"            => "pre",
      "pronoun"           => "pro",
      "する verb"          => "srv",
      "suffix"            => "suf",
      "transitive verb"   => "tvb",
    }

    has_many :audios, dependent: :destroy

    before_validation :set_accent_pattern, :clean_up

    validates :accent_position, numericality: { integer_only: true, greater_than_or_equal_to: MIN_ACCENT_POSITION, less_than_or_equal_to: MAX_READING }, allow_nil: true
    validates :accent_pattern, numericality: { integer_only: true, greater_than_or_equal_to: MIN_ACCENT_PATTERN, less_than_or_equal_to: MAX_ACCENT_PATTERN }, allow_nil: true
    validates :characters, presence: true, length: { maximum: MAX_CHARACTERS }, uniqueness: true
    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
    validates :meaning, presence: true, length: { maximum: MAX_MEANING }
    validates :meaning_mnemonic, presence: true
    validates :parts, presence: true, length: { maximum: MAX_PARTS }
    validates :reading, presence: true, length: { maximum: MAX_READING }
    validates :reading_mnemonic, presence: true
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    scope :by_characters,   -> { order(Arel.sql('characters COLLATE "C"')) }
    scope :by_level,        -> { order(:level, Arel.sql('characters COLLATE "C"')) }
    scope :by_last_noted,   -> { order(last_noted: :desc, level: :asc) }
    scope :by_last_updated, -> { order(last_updated: :desc, level: :asc) }
    scope :by_reading,      -> { order(Arel.sql('reading COLLATE "C"'), :level) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "reading"      then by_reading
        when "characters"   then by_characters
        when "last_noted"   then by_last_noted
        when "last_updated" then by_last_updated
        else                     by_level
        end
      if sql = cross_constraint(params[:vquery], %w{characters meaning reading})
        matches = matches.where(sql)
      end
      if sql = cross_constraint(params[:notes], %w{notes})
        matches = matches.where(sql)
      end
      if sql = numerical_constraint(params[:id], :wk_id)
        matches = matches.where(sql)
      end
      if params[:parts].is_a?(Array)
        parts = params[:parts].select{ |p| PARTS.has_value?(p) || p == "iax"  || p == "icx" }
        if parts.reject! { |p| p == "icx" }
          # search for godan verbs that look like ichidan verbs
          parts.push("gov") unless parts.include?("gov")
          if sql = cross_constraint("[#{IE}]る(,|$)", %w{reading})
            matches = matches.where(sql)
          end
        end
        if parts.reject! { |p| p == "iax" }
          # search for anything which looks like an i-adjective but isn't
          if sql = cross_constraint("い$", %w{characters})
            matches = matches.where(sql)
          end
          matches = matches.where("parts NOT LIKE '%iad%'")
        end
        if sql = cross_constraint(parts.join(" "), %w{parts})
          matches = matches.where(sql)
        end
      end
      if (level = params[:level].to_i) > 0
        matches = matches.where(level: level)
      end
      paginate(matches, params, path, opt)
    end

    def accent_display
      case accent_position
      when nil     then "?"
      when UNKNOWN then "?"
      else accent_position.to_s
      end
    end

    def intransitive?
      parts.match?(/ivb/)
    end

    def linked_characters
      characters.split('').map do |c|
        k = Wk::Kanji.find_by(character: c)
        k ? %Q{<a href="/wk/kanjis/#{k.id}">#{c}</a>} : c
      end.join('').html_safe
    end

    def notes_html
      to_html(notes)
    end

    def parts_of_speech
      parts.split(",").map{ |p| I18n.t("wk.parts.#{p}").downcase }.join(", ")
    end

    def pattern_colour
      if accent_pattern.present?
        %w/secondary success warning info/[accent_pattern] || "danger"
      elsif accent_position == UNKNOWN
        "secondary"
      else
        "outline-secondary"
      end
    end

    def pairs
      if transitive?
        Wk::VerbPair.where(transitive: self).to_a
      elsif intransitive?
        Wk::VerbPair.where(intransitive: self).to_a
      else
        []
      end
    end

    # to be able to remove old color classes in wk/vocabs/quick_accent_update.js.erb
    def pattern_colours
      %w/secondary success warning info danger outline-secondary/
    end

    def transitive?
      parts.match?(/tvb/)
    end

    # this is what gets run when a quick_accent_update ajax request is procesed
    # note that validation (see set_accent_pattern below) kicks in because of the save
    def update_accent(new_accent)
      if new_accent == "?"
        self.accent_position = nil
      elsif new_accent == "-"
        self.accent_position = UNKNOWN
      else
        i = new_accent.to_i
        self.accent_position = i if i >= 0
      end
      save
    end

    def self.update(days=nil)
      updates = 0
      creates = 0

      url, since = start_url("vocabulary", days)
      puts
      puts "vocabs since #{since}"
      puts "-----------------------"

      while url.present? do
        subjects, url = get_subjects(url)
        puts "subjects: #{subjects.size}"

        # updates and creates that don't need all vocab present
        subjects.each do |subject|
          check(subject, "vocab subject is not a hash #{subject.class}") { |v| v.is_a?(Hash) }

          wk_id = check(subject["id"], "vocab ID is not a positive integer ID") { |v| v.is_a?(Integer) && v > 0 }
          vocab = find_or_initialize_by(wk_id: wk_id)
          context = "vocab (#{wk_id})"

          last_updated =
            begin
              Date.parse(subject["data_updated_at"].to_s)
            rescue ArgumentError
              nil
            end
          vocab.last_updated = check(last_updated, "#{context} has no valid last update date") { |v| v.is_a?(Date) }

          data = check(subject["data"], "#{context} doesn't have a data hash") { |v| v.is_a?(Hash) }

          vocab.characters = check(data["characters"], "#{context} doesn't have valid characters") { |v| v.is_a?(String) && v.present? && v.length <= MAX_CHARACTERS }
          context[-1,1] = ", #{vocab.characters})"

          vocab.level = check(data["level"], "#{context} doesn't have a valid level") { |v| v.is_a?(Integer) && v > 0 && v <= MAX_LEVEL }
          context[-1,1] = ", #{vocab.level})"

          meanings = check(data["meanings"], "#{context} doesn't have a meanings array") { |v| v.is_a?(Array) && v.size > 0 }
          primary = []
          secondary = []
          meanings.each do |m|
            if m.is_a?(Hash) && m["meaning"].is_a?(String) && m["meaning"].present?
              meaning = m["meaning"]
              if m["primary"]
                primary.push(meaning)
              else
                secondary.push(meaning)
              end
            end
          end
          check(primary, "#{context} doesn't have a primary meaning") { |v| v.is_a?(Array) && v.size > 0 }
          meaning = primary.concat(secondary).join(", ")
          vocab.meaning = check(meaning.downcase, "#{context} meaning is too long (#{meaning.length})") { |v| v.length <= MAX_MEANING }

          readings = check(data["readings"], "#{context} doesn't have a readings array") { |v| v.is_a?(Array) && v.size > 0 }
          primary = []
          secondary = []
          readings.each do |r|
            if r.is_a?(Hash) && r["reading"].is_a?(String) && r["reading"].present?
              reading = r["reading"]
              reading = reading.katakana if r["type"] == "onyomi"
              if r["primary"]
                primary.push(reading)
              else
                secondary.push(reading)
              end
            end
          end
          check(primary, "#{context} doesn't have any primary readings") { |v| v.is_a?(Array) && v.size > 0 }
          reading = primary.concat(secondary).join(", ")
          vocab.reading = check(reading, "#{context} reading is too long (#{reading.length})") { |v| v.length <= MAX_READING }
          context[-1,1] = ", #{vocab.reading})"

          vocab.meaning_mnemonic = check(data["meaning_mnemonic"], "#{context} doesn't have a meaning mnemonic") { |v| v.is_a?(String) && v.present? }
          vocab.reading_mnemonic = check(data["reading_mnemonic"], "#{context} doesn't have a reading mnemonic") { |v| v.is_a?(String) && v.present? }

          check(data["parts_of_speech"], "#{context} doesn't have any parts of speech") { |v| v.is_a?(Array) && v.size > 0 }
          parts = []
          data["parts_of_speech"].each do |part|
            parts.push(check(PARTS[part], "#{context} has invalid part of speech (#{part.is_a?(String) ? part : part.class})") { |v| !v.nil? })
          end
          correct_parts(vocab.characters, parts)
          parts = parts.join(",")
          vocab.parts = check(parts, "#{context} parts of speech is too long (#{parts.length})") { |v| v.length <= MAX_PARTS }

          audios = check(data["pronunciation_audios"], "#{context} doesn't have any audios") { |v| v.is_a?(Array) && v.size > 0 }
          audios.map! do |audio|
            if audio.is_a?(Hash) && audio["content_type"] == "audio/mpeg"
              file = audio["url"]
              meta = audio["metadata"]
              id = meta["source_id"] if meta.is_a?(Hash)
              if file.is_a?(String) && file.delete_prefix!(Wk::Audio::DEFAULT_BASE) && file.length <= Wk::Audio::MAX_FILE && id.is_a?(Integer) && id > 0
                { file: file, wk_id: id }
              end
            end
          end.compact!
          check(audios, "#{context} has no valid mpeg audios") { |v| !v.empty? }
          old_audio_ids = new_audio_ids = audio_changes = nil
          if vocab.new_record?
            vocab.audios.build(audios)
          else
            old_audio_ids = vocab.audios.pluck(:wk_id).sort.join(", ")
            new_audio_ids = audios.map{ |a| a[:wk_id] }.sort.join(", ")
            if old_audio_ids != new_audio_ids
              audio_changes = [old_audio_ids, new_audio_ids]
            end
          end

          if vocab.new_record?
            vocab.save!
            creates += 1
          else
            changes = vocab.changes
            changes["audios"] = audio_changes if audio_changes
            updates += 1 if vocab.update_performed?(changes, old_audio_ids: old_audio_ids, new_audios: audios)
          end
        end
      end

      puts "updates: #{updates}"
      puts "creates: #{creates}"
    end

    def update_performed?(changes, old_audio_ids: nil, new_audios: nil)
      return false if changes.empty?

      puts "vocab #{wk_id}:"
      show_change(changes, "level")
      show_change(changes, "meaning")
      show_change(changes, "reading")
      show_change(changes, "parts")
      show_change(changes, "meaning_mnemonic", max: 50)
      show_change(changes, "reading_mnemonic", max: 50)
      show_change(changes, "audios", no_change: old_audio_ids)
      show_change(changes, "last_updated")

      return false unless permission_granted?
      save!
      if changes["audios"]
        self.audios = []
        self.audios.create!(new_audios)
      end
      return true
    end

    # corrections to WK parts of speech data
    def self.correct_parts(characters, parts)
      if characters == "向く" && !parts.include?("ivb")
        parts.unshift("ivb")
      elsif characters == "足りない" && parts.include?("ivb")
        parts.unshift("iad")
        parts.delete("ivb")
      end
    end

    private

    def set_accent_pattern
      if changes.has_key?("reading") || changes.has_key?("accent_position")
        if accent_position.is_a?(Integer)
          morae = count_morae
          self.accent_position = morae if accent_position > morae
          self.accent_position = UNKNOWN if accent_position < MIN_ACCENT_POSITION
          self.accent_pattern =
            case accent_position
            when UNKNOWN
              nil
            when 0
              HEIBAN
            when 1
              ATAMADAKA
            when morae
              ODAKA
            else
              NAKADAKA
            end
        else
          self.accent_pattern = nil
        end
      end
    end

    def count_morae
      # get a throwaway copy of the reading, handling the nil case
      string = reading.to_s.dup
      # make sure to get only the first reading if there's more than one
      string.sub!(/,.*/, "")
      # count 1 for all hiragana, katakana and the katakana elongation symbol
      full = string.each_char.map{ |c| c =~ /\A[ぁ-んァ-ンー]\z/ ? 1 : 0 }.sum
      # count 1 for all small hiragana and katakana (but not the っ or ッ)
      tiny = string.each_char.map{ |c| c =~ /\A[ぁァぃィぅゥぇェぉォゃャゅュょョ]\z/ ? 1 : 0 }.sum
      # the number of morae is the difference between these two
      full - tiny
    end

    def clean_up
      self.notes = nil unless notes.present?
    end
  end
end
