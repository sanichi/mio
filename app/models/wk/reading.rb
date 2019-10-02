module Wk
  class Reading < ActiveRecord::Base
    include Wanikani

    # pitch accent patterns
    HEIBAN = 0
    ATAMADAKA = 1
    NAKADAKA = 2
    ODAKA = 3

    # special accent_position which means we've looked but can't find out what it should be
    # when accent_position is nil, it means we haven't even tried to find out yet
    UNKNOWN = -1

    MAX_CHARACTERS = 24
    MAX_ACCENT_PATTERN = ODAKA
    MIN_ACCENT_PATTERN = HEIBAN
    MIN_ACCENT_POSITION = UNKNOWN

    before_validation :set_accent_pattern

    validates :accent_position, numericality: { integer_only: true, greater_than_or_equal_to: MIN_ACCENT_POSITION, less_than_or_equal_to: MAX_CHARACTERS }, allow_nil: true
    validates :accent_pattern, numericality: { integer_only: true, greater_than_or_equal_to: MIN_ACCENT_PATTERN, less_than_or_equal_to: MAX_ACCENT_PATTERN }, allow_nil: true
    validates :characters, presence: true, length: { maximum: MAX_CHARACTERS }

    has_one :vocab
    has_many :audios, dependent: :destroy

    default_scope { order(primary: :desc) }

    def accent_display
      case accent_position
      when nil     then "?"
      when UNKNOWN then "?"
      else accent_position.to_s
      end
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

    # to be able to remove old color classes in wk/readings/quick_accent_update.js.erb
    def pattern_colours
      %w/secondary success warning info danger outline-secondary/
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
      stats = Hash.new(0)
      new_wk_ids = []
      old_wk_ids = Vocab.pluck(:wk_id)

      url, since = start_url("vocabulary", days)
      puts
      puts "readings since #{since}"
      puts "-------------------------"

      while url.present? do
        subjects, url = get_subjects(url)
        puts "subjects: #{subjects.size}"

        # updates and creates that don't need all vocab present
        subjects.each do |subject|
          check(subject, "vocab subject is not a hash #{subject.class}") { |v| v.is_a?(Hash) }

          wk_id = check(subject["id"], "vocab ID is not a positive integer ID") { |v| v.is_a?(Integer) && v > 0 }
          vocab = Vocab.find_by(wk_id: wk_id)
          if vocab
            stats["matched vocabs"] += 1
            old_wk_ids.delete(wk_id)
          else
            new_wk_ids.push(wk_id)
            next
          end
          context = "vocab (#{wk_id})"

          data = check(subject["data"], "#{context} doesn't have a data hash") { |v| v.is_a?(Hash) }

          readings = check(data["readings"], "#{context} doesn't have a readings array") { |v| v.is_a?(Array) && v.size > 0 }
          wk_readings = {}
          readings.each do |r|
            check(r, "#{context} has an invalid reading") { |v| v.is_a?(Hash) && v["reading"].is_a?(String) && v["reading"].present? && (v["primary"] == true || v["primary"] == false) }
            wk_readings[r["reading"]] = r["primary"]
          end
          wk_readings.each do | characters, primary |
            db_reading = Reading.find_by(vocab_id: vocab.id, characters: characters)
            if db_reading
              if db_reading.primary == primary
                stats["matched readings"] += 1
              else
                db_reading.update_column(:primary, primary)
                stats["updated readings"] += 1
              end
            else
              vocab.readings << Reading.create!(vocab_id: vocab.id, characters: characters, primary: primary)
              stats["new readings"] += 1
            end
          end
          db_readings = {}
          vocab.readings.each do |reading|
            if wk_readings.has_key?(reading.characters)
              db_readings[reading.characters] = reading
            else
              vocab.readings.delete(reading)
              stats["old readings"] += 1
            end
          end

          audios = check(data["pronunciation_audios"], "#{context} doesn't have an audios array") { |v| v.is_a?(Array) && v.size > 0 }
          wk_audios = Hash.new { |h, k| h[k] = [] }
          audios.each do |a|
            check(a, "#{context} has an invalid audio") { |v| v.is_a?(Hash) && v["url"].is_a?(String) && v["url"].starts_with?(Audio::DEFAULT_BASE) && v["metadata"].is_a?(Hash) && v["content_type"].is_a?(String) && v["content_type"].present? && v["metadata"]["pronunciation"].is_a?(String) && wk_readings.has_key?(v["metadata"]["pronunciation"]) }
            if a["content_type"] == "audio/mpeg"
              wk_audios[a["metadata"]["pronunciation"]].push(a["url"].delete_prefix(Audio::DEFAULT_BASE))
            end
          end
          db_readings.each do | characters, reading |
            wk_audios[characters].each do |file|
              db_audio = Audio.find_by(reading_id: reading.id, file: file)
              if db_audio
                stats["matched audios"] += 1
              else
                reading.audios << Audio.create!(reading_id: reading.id, file: file)
                stats["new audios"] += 1
              end
            end
            reading.audios.each do |audio|
              unless wk_audios[characters].include?(audio.file)
                reading.audios.delete(audio)
                stats["old audios"] += 1
              end
            end
          end
        end
      end

      extra = {}
      max_extra = 55
      unless new_wk_ids.empty?
        key = "WK vocabs not in DB"
        stats[key] = new_wk_ids.size
        extra[key] = "(#{new_wk_ids.sort.join(',')})".truncate(max_extra)
      end
      if days.nil? && old_wk_ids.size > 0
        key = "DB vocabs not in WK"
        stats[key] = old_wk_ids.size
        extra[key] = "(#{old_wk_ids.sort.join(',')})".truncate(max_extra)
      end

      puts "stats:"
      stats.sort_by { |k, v| v }.reverse.each do |k, v|
        puts "  %s%s %s %s" % [k, "." * (25 - k.length), v, extra[k]]
      end
    end

    private

    def set_accent_pattern
      if changes.has_key?("characters") || changes.has_key?("accent_position")
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
      string = characters.to_s.dup
      # make sure to get only the first reading if there's more than one
      string.sub!(/,.*/, "")
      # count 1 for all hiragana, katakana and the katakana elongation symbol
      full = string.each_char.map{ |c| c =~ /\A[ぁ-んァ-ンー]\z/ ? 1 : 0 }.sum
      # count 1 for all small hiragana and katakana (but not the っ or ッ)
      tiny = string.each_char.map{ |c| c =~ /\A[ぁァぃィぅゥぇェぉォゃャゅュょョ]\z/ ? 1 : 0 }.sum
      # the number of morae is the difference between these two
      full - tiny
    end
  end
end
