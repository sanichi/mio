module Wk
  class Kanji < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Wanikani

    MAX_MEANING = 128

    before_validation :truncate

    validates :character, length: { is: 1 }, uniqueness: true
    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
    validates :meaning, presence: true, length: { maximum: MAX_MEANING }
    validates :meaning_mnemonic, presence: true
    validates :reading_mnemonic, presence: true
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    scope :by_character, -> { order(:character) }
    scope :by_level,     -> { order(:level, :character) }
    scope :by_meaning,   -> { order(:meaning, :character) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "meaning" then by_meaning
        when "level"   then by_level
        else                by_character
        end
      if sql = cross_constraint(params[:query], %w{character meaning})
        matches = matches.where(sql)
      end
      if sql = numerical_constraint(params[:id], :wk_id)
        matches = matches.where(sql)
      end
      if (level = params[:level].to_i) > 0
        matches = matches.where(level: level)
      end
      paginate(matches, params, path, opt)
    end

    def self.update
      updates = 0
      creates = 0
      url = start_url("kanji")
      puts "kanjis"
      puts "------"

      while url.present? do
        data, url = get_data(url)
        puts "records: #{data.size}"

        data.each do |record|
          check(record, "kanji record is not a hash #{record.class}") { |v| v.is_a?(Hash) }

          wk_id = check(record["id"], "kanji ID is not a positive integer ID") { |v| v.is_a?(Integer) && v > 0 }
          kanji = find_or_initialize_by(wk_id: wk_id)
          subject = "kanji (#{wk_id})"

          kdata = check(record["data"], "#{subject} doesn't have a data hash") { |v| v.is_a?(Hash) }

          kanji.character = check(kdata["characters"], "#{subject} doesn't have a character") { |v| v.is_a?(String) && v.length == 1 }
          subject[-1,1] = ", #{kanji.character})"

          kanji.level = check(kdata["level"], "#{subject} doesn't have a valid level") { |v| v.is_a?(Integer) && v > 0 && v <= MAX_LEVEL }
          subject[-1,1] = ", #{kanji.level})"

          meaning_mnemonic = check(kdata["meaning_mnemonic"], "#{subject} doesn't have a meaning mnemonic") { |v| v.is_a?(String) && v.present? }
          meaning_hint = kdata["meaning_hint"]
          kanji.meaning_mnemonic = meaning_hint ? "<p>#{meaning_mnemonic}</p><p>#{meaning_hint}</p>" : meaning_mnemonic

          reading_mnemonic = check(kdata["reading_mnemonic"], "#{subject} doesn't have a reading mnemonic") { |v| v.is_a?(String) && v.present? }
          reading_hint = kdata["reading_hint"]
          kanji.reading_mnemonic = reading_hint ? "<p>#{reading_mnemonic}</p><p>#{reading_hint}</p>" : reading_mnemonic

          meanings = check(kdata["meanings"], "#{subject} doesn't have a meanings array") { |v| v.is_a?(Array) && v.size > 0 }
          primary = meanings.map { |m| m["meaning"] if m.is_a?(Hash) && m["primary"] == true && m["meaning"].present? }.compact
          check(primary, "#{subject} doesn't have a primary meaning") { |v| v.is_a?(Array) && v.size > 0 }
          alternative = meanings.map { |m| m["meaning"] if m.is_a?(Hash) && m["primary"] == false && m["meaning"].present? }.compact
          kanji.meaning = primary.concat(alternative).join(", ")
          subject[-1,1] = ", #{kanji.meaning})"

          if kanji.new_record?
            kanji.save!
            creates += 1
          else
            updates += kanji.check_update
          end
        end
      end

      puts "updates: #{updates}"
      puts "creates: #{creates}"
    end

    def check_update
      return 0 unless changed?

      changes = self.changes

      puts "kanji #{wk_id}:"
      show_change(changes, "character")
      show_change(changes, "level")
      show_change(changes, "meaning")
      show_change(changes, "meaning_mnemonic", max: 50)
      show_change(changes, "reading_mnemonic", max: 50)

      return 0 unless permission_granted?
      save!
      return 1
    end

    private

    def truncate
      self.meaning = meaning&.truncate(MAX_MEANING)
    end
  end
end
