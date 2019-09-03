module Wk
  class Kanji < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Wanikani

    validates :character, length: { is: 1 }, uniqueness: true
    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
    validates :meaning_mnemonic, presence: true
    validates :reading_mnemonic, presence: true
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    scope :by_character, -> { order(:character) }
    scope :by_level,     -> { order(:level, :character) }

    def self.search(params, path, opt={})
      matches = by_level
        case params[:order]
        when "level" then by_level
        else              by_character
        end
      if sql = cross_constraint(params[:query], %w{character})
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
          raise "kanji data is not a hash #{record.class}" unless record&.is_a?(Hash)
          wk_id = record["id"]
          raise "kanji doesn't have a positive integer ID (#{wk_id})" unless wk_id.is_a?(Integer) && wk_id > 0
          kanji = find_or_initialize_by(wk_id: wk_id)

          kdata = record["data"]
          raise "kanji #{wk_id} doesn't have a data hash (#{kdata.class})" unless kdata.is_a?(Hash)

          level = kdata["level"]
          raise "kanji #{wk_id} doesn't have a valid level (#{level})" unless level.is_a?(Integer) && level > 0 && level <= MAX_LEVEL
          kanji.level = level

          character = kdata["characters"]
          raise "kanji #{wk_id} (#{level}) doesn't have a character (#{character})" unless character.is_a?(String) && character.length == 1
          kanji.character = character

          meaning_mnemonic = kdata["meaning_mnemonic"]
          raise "kanji #{wk_id} (#{level}, #{character}) doesn't have a meaning mnemonic (#{meaning_mnemonic.class})" unless meaning_mnemonic.is_a?(String) && meaning_mnemonic.present?
          meaning_hint = kdata["meaning_hint"]
          kanji.meaning_mnemonic = meaning_hint ? "<p>#{meaning_mnemonic}</p><p>#{meaning_hint}</p>" : meaning_mnemonic

          reading_mnemonic = kdata["reading_mnemonic"]
          raise "kanji #{wk_id} (#{level}, #{character}) doesn't have a reading mnemonic (#{reading_mnemonic.class})" unless reading_mnemonic.is_a?(String) && reading_mnemonic.present?
          reading_hint = kdata["reading_hint"]
          kanji.reading_mnemonic = reading_hint ? "<p>#{reading_mnemonic}</p><p>#{reading_hint}</p>" : reading_mnemonic

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
      show_change(changes, "meaning_mnemonic", max: 50)
      show_change(changes, "reading_mnemonic", max: 50)

      return 0 unless permission_granted?
      save!
      return 1
    end
  end
end
