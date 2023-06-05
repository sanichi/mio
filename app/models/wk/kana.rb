module Wk
  class Kana < ApplicationRecord
    include Constrainable
    include Pageable
    include Remarkable
    include Vocabable
    include Wanikani

    before_validation :clean_up, :set_accent_pattern

    validates :characters, presence: true, length: { maximum: Wk::Vocab::MAX_CHARACTERS }, uniqueness: true
    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
    validates :meaning, presence: true, length: { maximum: Wk::Vocab::MAX_MEANING }
    validates :meaning_mnemonic, presence: true
    validates :parts, presence: true, length: { maximum: Wk::Vocab::MAX_PARTS }
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    scope :by_characters,   -> { order(Arel.sql('characters COLLATE "C"')) }
    scope :by_level,        -> { order(:level, Arel.sql('characters COLLATE "C"')) }
    scope :by_last_updated, -> { order(last_updated: :desc, level: :asc) }

    has_many :audios, as: :audible, dependent: :destroy

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "characters"   then by_characters
        when "last_updated" then by_last_updated
        else                     by_level
        end
      if sql = cross_constraint(params[:hkquery], %w{characters meaning})
        matches = matches.where(sql)
      end
      if sql = cross_constraint(params[:notes], %w{notes})
        matches = matches.where(sql)
      end
      if sql = numerical_constraint(params[:id], :wk_id)
        matches = matches.where(sql)
      end
      if params[:parts].is_a?(Array)
        parts = params[:parts].select{ |p| Wk::Vocab::PARTS.has_value?(p) }
        if sql = cross_constraint(parts.join(" "), %w{parts})
          matches = matches.where(sql)
        end
      end
      if (level = params[:level].to_i) > 0
        matches = matches.where(level: level)
      end
      case params[:hidden]
      when "hidden"
        matches = matches.where(hidden: true)
      when "visible"
        matches = matches.where(hidden: false)
      end
      paginate(matches, params, path, opt)
    end

    def any_notes?
      notes.present?
    end

    def notes_html
      notes_plus = link_vocabs(notes.to_s)
      notes_plus.sub(/\n+\z/, "")
      notes_plus += "\n\n" if notes_plus.present?
      to_html(notes_plus)
    end

    def intransitive?
      parts.match?(/ivb/)
    end

    def transitive?
      parts.match?(/tvb/)
    end

    def parts_of_speech
      parts.split(",").map{ |p| I18n.t("wk.parts.#{p}").downcase }.join(", ")
    end

    def accent_display
      case accent_position
      when nil                  then "?"
      when Wk::Reading::UNKNOWN then "?"
      else accent_position.to_s
      end
    end

    def pattern_colour
      if accent_pattern.present?
        %w/secondary success warning info/[accent_pattern] || "danger"
      elsif accent_position == Wk::Reading::UNKNOWN
        "secondary"
      else
        "outline-secondary"
      end
    end

    # to be able to remove old color classes in wk/kanas/quick_accent_update.js.erb
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
      count = Hash.new(0)
      old_wk_ids = pluck(:wk_id)

      url, since = start_url("kana_vocabulary", days)
      puts
      puts "kana since #{since}"
      puts "-------------------"

      while url.present? do
        subjects, url = get_subjects(url)
        puts "subjects.. #{subjects.size}"

        # updates and creates that don't need all vocab present
        subjects.each do |subject|
          check(subject, "kana subject is not a hash #{subject.class}") { |v| v.is_a?(Hash) }

          wk_id = check(subject["id"], "kana ID is not a positive integer ID") { |v| v.is_a?(Integer) && v > 0 }
          kana = find_or_initialize_by(wk_id: wk_id)
          context = "kana (#{wk_id})"

          last_updated =
            begin
              Date.parse(subject["data_updated_at"].to_s)
            rescue ArgumentError
              nil
            end
          kana.last_updated = check(last_updated, "#{context} has no valid last update date") { |v| v.is_a?(Date) }

          data = check(subject["data"], "#{context} doesn't have a data hash") { |v| v.is_a?(Hash) }

          check(data, "#{context} doesn't have a hidden field") { |v| v.has_key?("hidden_at") }
          kana.hidden = !!data["hidden_at"]
          count[:hidden] += 1 if kana.hidden

          kana.characters = check(data["characters"], "#{context} doesn't have valid characters") { |v| v.is_a?(String) && v.present? && v.length <= Wk::Vocab::MAX_CHARACTERS }
          context[-1,1] = ", #{kana.characters})"

          kana.level = check(data["level"], "#{context} doesn't have a valid level") { |v| v.is_a?(Integer) && v > 0 && v <= MAX_LEVEL }
          context[-1,1] = ", #{kana.level})"

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
          check(primary, "#{context} doesn't have a primary meaning") { |v| v.size > 0 }
          meaning = primary.concat(secondary).join(", ")
          kana.meaning = check(meaning.downcase, "#{context} meaning is too long (#{meaning.length})") { |v| v.length <= Wk::Vocab::MAX_MEANING }

          kana.meaning_mnemonic = check(data["meaning_mnemonic"], "#{context} doesn't have a meaning mnemonic") { |v| v.is_a?(String) && v.present? }

          check(data["parts_of_speech"], "#{context} doesn't have any parts of speech") { |v| v.is_a?(Array) && v.size > 0 }
          parts = []
          data["parts_of_speech"].each do |part|
            parts.push(check(Wk::Vocab::PARTS[part], "#{context} has invalid part of speech (#{part.is_a?(String) ? part : part.class})") { |v| !v.nil? })
          end
          parts = parts.join(",")
          kana.parts = check(parts, "#{context} parts of speech is too long (#{parts.length})") { |v| v.length <= Wk::Vocab::MAX_PARTS }

          check(data["pronunciation_audios"], "#{context} doesn't have any pronunciation audios") { |v| v.is_a?(Array) }
          wk_files = []
          data["pronunciation_audios"].each_with_index do |audio, i|
            check(audio, "#{context} audio item #{i} is not a hash") { |v| v.is_a?(Hash) }
            next unless audio["content_type"] == "audio/mpeg"
            check(audio["url"], "#{context} audio hash #{i} has no string url") { |v| v.is_a?(String) }
            check(audio["url"], "#{context} audio url #{i} doesn't start with default base") { |v| v.starts_with?(Wk::Audio::DEFAULT_BASE) }
            file = audio["url"]
            file[Wk::Audio::DEFAULT_BASE] = ""
            check(file, "#{context} audio file #{i} (#{file}) doesn't have the right size") { |v| v.length > 0 && v.length <= Wk::Audio::MAX_FILE }
            wk_files.push(file) unless wk_files.include?(file)
          end

          if kana.new_record?
            kana.save!
            wk_files.each {|file| kana.audios.create!(file: file)}
            count[:creates] += 1
          else
            old_wk_ids.delete(wk_id)
            changes = kana.changes
            db_files = kana.audios.map(&:file)
            new_files = wk_files - db_files
            old_files = db_files - wk_files
            count[:updates] += 1 if kana.update_performed?(changes, new_files, old_files)
          end
          count[:total] += 1
        end
      end

      puts "total..... #{count[:total]}"
      puts "hidden.... #{count[:hidden]}"
      puts "updates... #{count[:updates]}"
      puts "creates... #{count[:creates]}"

      if days.nil? && old_wk_ids.size > 0
        puts "DB kana no longer in WK #{old_wk_ids.size}: #{old_wk_ids.sort.join(',')}"
      end
    end

    def update_performed?(changes, new_files, old_files)
      return false if changes.empty? && new_files.empty? && old_files.empty?

      puts "kana #{wk_id}:"
      show_change(changes, "characters")
      show_change(changes, "hidden")
      show_change(changes, "last_updated")
      show_change(changes, "level")
      show_change(changes, "meaning")
      show_change(changes, "meaning_mnemonic", max: 50)
      show_change(changes, "parts")
      show_other_change("new audios", new_files.join(", ")) unless new_files.empty?
      show_other_change("old audios", old_files.join(", ")) unless old_files.empty?

      ask = changes.size == 1 && changes.has_key?("last_updated") ? false : true
      return false if ask && !permission_granted?

      save! unless changes.empty?
      audios.each{|audio| audios.delete(audio) if old_files.include?(audio.file)} unless old_files.empty?
      new_files.each{|file| audios.create!(file: file)} unless new_files.empty?

      return true
    end

    private

    def set_accent_pattern
      if changes.has_key?("characters") || changes.has_key?("accent_position")
        if accent_position.is_a?(Integer)
          morae = count_morae
          self.accent_position = morae if accent_position > morae
          self.accent_position = UNKNOWN if accent_position < Wk::Reading::MIN_ACCENT_POSITION
          self.accent_pattern =
            case accent_position
            when Wk::Reading::UNKNOWN
              nil
            when 0
              Wk::Reading::HEIBAN
            when 1
              Wk::Reading::ATAMADAKA
            when morae
              Wk::Reading::ODAKA
            else
              Wk::Reading::NAKADAKA
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

    def clean_up
      self.notes = nil unless notes.present?
    end
  end
end
