module Wk
  class Vocab < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Wanikani

    IE = "いえきけぎげしせじぜちてぢでにねひへびべぴぺみめりれ"
    MAX_CHARACTERS = 24
    MAX_MEANING = 256
    MAX_PARTS = 80
    MAX_READING = 48
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
    SILENT_PARTS = { "iax" => true, "icx" => true }

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
    scope :by_last_updated, -> { order(last_updated: :desc, level: :asc) }
    scope :by_reading,      -> { order(Arel.sql('reading COLLATE "C"'), :level) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "reading"      then by_reading
        when "characters"   then by_characters
        when "last_updated" then by_last_updated
        else                     by_level
        end
      if sql = cross_constraint(params[:vquery], %w{characters meaning reading})
        matches = matches.where(sql)
      end
      if sql = numerical_constraint(params[:id], :wk_id)
        matches = matches.where(sql)
      end
      if params[:parts].is_a?(Array)
        parts = params[:parts].select{ |p| PARTS.has_value?(p) || SILENT_PARTS.has_key?(p) }.join(" ")
        if sql = cross_constraint(parts, %w{parts})
          matches = matches.where(sql)
        end
      end
      if (level = params[:level].to_i) > 0
        matches = matches.where(level: level)
      end
      paginate(matches, params, path, opt)
    end

    def parts_of_speech
      parts.split(",").reject{ |p| SILENT_PARTS[p] }.map{ |p| I18n.t("wk.parts.#{p}") }.join(", ")
    end

    def self.update
      updates = 0
      creates = 0
      url = start_url("vocabulary")

      puts "vocabs"
      puts "------"

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
          # add my own custom types
          parts.push "icx" if vocab.reading.match(/[#{IE}]る(,|\z)/) && parts.include?("gov") # looks like an iru-eru verb but is actually godan
          parts.push "iax" if vocab.characters.match(/い\z/) && !parts.include?("iad")        # looks like an i-adjective but isn't
          parts = parts.join(",")
          vocab.parts = check(parts, "#{context} parts of sppech is too long (#{parts.length})") { |v| v.length <= MAX_PARTS }

          if vocab.new_record?
            vocab.save!
            creates += 1
          else
            changes = vocab.changes
            updates += 1 if vocab.update_performed?(changes)
          end
        end
      end

      puts "updates: #{updates}"
      puts "creates: #{creates}"
    end

    def update_performed?(changes)
      return false if changes.empty?

      puts "vocab #{wk_id}:"
      show_change(changes, "level")
      show_change(changes, "meaning")
      show_change(changes, "reading")
      show_change(changes, "parts")
      show_change(changes, "meaning_mnemonic", max: 50)
      show_change(changes, "reading_mnemonic", max: 50)
      show_change(changes, "last_updated")

      return false unless permission_granted?
      save!
      return true
    end
  end
end
