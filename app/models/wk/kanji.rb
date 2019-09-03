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
