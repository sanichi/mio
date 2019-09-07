module Wk
  class Kanji < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Wanikani

    MAX_MEANING = 128
    MAX_READING = 128

    has_and_belongs_to_many :radicals
    has_and_belongs_to_many :similar_kanjis, class_name: "Kanji", association_foreign_key: "similar_id"

    validates :character, length: { is: 1 }, uniqueness: true
    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
    validates :last_updated, presence: true
    validates :meaning, presence: true, length: { maximum: MAX_MEANING }
    validates :meaning_mnemonic, presence: true
    validates :reading, presence: true, length: { maximum: MAX_READING }
    validates :reading_mnemonic, presence: true
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    scope :by_character,    -> { order(:character) }
    scope :by_level,        -> { order(:level, :character) }
    scope :by_meaning,      -> { order(:meaning, :level) }
    scope :by_reading,      -> { order(:reading, :level) }
    scope :by_last_updated, -> { order(last_updated: :desc, level: :asc) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "last_updated" then by_last_updated
        when "level"        then by_level
        when "meaning"      then by_meaning
        when "reading"      then by_reading
        else                     by_character
        end
      if sql = cross_constraint(params[:query], %w{character meaning reading})
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
      new_similarities = {}
      url = start_url("kanji")
      radical_from_id = Wk::Radical.all.each_with_object({}) { |r, h| h[r.wk_id] = r }

      puts "kanjis"
      puts "------"

      while url.present? do
        data, url = get_data(url)
        puts "records: #{data.size}"

        # updates and creates that don't need all kanji present
        data.each do |record|
          check(record, "kanji record is not a hash #{record.class}") { |v| v.is_a?(Hash) }

          wk_id = check(record["id"], "kanji ID is not a positive integer ID") { |v| v.is_a?(Integer) && v > 0 }
          kanji = find_or_initialize_by(wk_id: wk_id)
          subject = "kanji (#{wk_id})"

          last_updated =
            begin
              Date.parse(record["data_updated_at"].to_s)
            rescue ArgumentError
              nil
            end
          kanji.last_updated = check(last_updated, "#{subject} has no valid last update date") { |v| v.is_a?(Date) }

          kdata = check(record["data"], "#{subject} doesn't have a data hash") { |v| v.is_a?(Hash) }

          kanji.character = check(kdata["characters"], "#{subject} doesn't have a character") { |v| v.is_a?(String) && v.length == 1 }
          subject[-1,1] = ", #{kanji.character})"

          kanji.level = check(kdata["level"], "#{subject} doesn't have a valid level") { |v| v.is_a?(Integer) && v > 0 && v <= MAX_LEVEL }
          subject[-1,1] = ", #{kanji.level})"

          meanings = check(kdata["meanings"], "#{subject} doesn't have a meanings array") { |v| v.is_a?(Array) && v.size > 0 }
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
          check(primary, "#{subject} doesn't have a primary meaning") { |v| v.is_a?(Array) && v.size > 0 }
          meaning = primary.concat(secondary).join(", ")
          kanji.meaning = check(meaning, "#{subject} meaning is too long (#{meaning.length})") { |v| v.length <= MAX_MEANING }
          subject[-1,1] = ", #{kanji.meaning})"

          readings = check(kdata["readings"], "#{subject} doesn't have a readings array") { |v| v.is_a?(Array) && v.size > 0 }
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
          check(primary, "#{subject} doesn't have any primary readings") { |v| v.is_a?(Array) && v.size > 0 }
          reading = primary.concat(secondary).join(", ")
          kanji.reading = check(reading, "#{subject} reading is too long (#{reading.length})") { |v| v.length <= MAX_READING }
          subject[-1,1] = ", #{kanji.reading})"

          meaning_mnemonic = check(kdata["meaning_mnemonic"], "#{subject} doesn't have a meaning mnemonic") { |v| v.is_a?(String) && v.present? }
          meaning_hint = kdata["meaning_hint"]
          kanji.meaning_mnemonic = meaning_hint ? "<p>#{meaning_mnemonic}</p><p>#{meaning_hint}</p>" : meaning_mnemonic

          reading_mnemonic = check(kdata["reading_mnemonic"], "#{subject} doesn't have a reading mnemonic") { |v| v.is_a?(String) && v.present? }
          reading_hint = kdata["reading_hint"]
          kanji.reading_mnemonic = reading_hint ? "<p>#{reading_mnemonic}</p><p>#{reading_hint}</p>" : reading_mnemonic

          component_ids = check(kdata["component_subject_ids"], "#{subject} doesn't have a radicals array") { |v| v.is_a?(Array) && v.size > 0 }
          old_radical_ids = kanji.new_record? ? [] : kanji.radicals.pluck(:wk_id)
          new_radical_ids = component_ids.map do |v|
            check(v, "#{subject} has invalid radical ID (#{v}) }") { |v| radical_from_id.has_key?(v) }
          end
          new_radical_ids.uniq! # just in case, although in this case (unlike similar kanjis) there seem to be no duplicates
          same_radicals = new_radical_ids.size == old_radical_ids.size && new_radical_ids.to_set == old_radical_ids.to_set
          radicals = component_ids.map { |wk_id| radical_from_id[wk_id] }

          old_similar_ids = kanji.new_record? ? [] : kanji.similar_kanjis.pluck(:wk_id)
          new_similar_ids = kdata["visually_similar_subject_ids"]
          new_similar_ids = [] unless new_similar_ids.is_a?(Array) && new_similar_ids.all? { |id| id.is_a?(Integer) && id > 0 }
          new_similar_ids.uniq! # sadly, WK data is not always unique
          new_similar_ids.reject! { |id| id == wk_id } # don't allow self-similarity just in case
          same_similar_kanjis = new_similar_ids.size == old_similar_ids.size && new_similar_ids.to_set == old_similar_ids.to_set

          if kanji.new_record?
            kanji.save!
            kanji.radicals = radicals
            creates += 1
          else
            changes = kanji.changes
            options = {}
            if same_radicals
              options[:old_radical_ids] = old_radical_ids.join(", ")
            else
              changes["radicals"] = [old_radical_ids.join(", "), new_radical_ids.join(", ")]
              options[:new_radicals] = radicals
            end
            if same_similar_kanjis
              options[:old_similar_ids] = old_similar_ids.join(", ")
            else
              changes["similar_kanjis"] = [old_similar_ids.join(", "), new_similar_ids.join(", ")]
            end
            if kanji.update_performed?(changes, options)
              updates += 1
            else
              # if we don't update the other attributes, don't update similar kanjis either
              same_similar_kanjis = true
            end
          end

          # these updates will be done later after all kanji are in place
          new_similarities[kanji] = new_similar_ids unless same_similar_kanjis
        end
      end

      # updates that need all kanji present
      kanji_from_id = Wk::Kanji.all.each_with_object({}) { |k, h| h[k.wk_id] = k }
      new_similarities.each do |kanji, similar_ids|
        similar_kanjis = similar_ids.map do |wk_id|
          check(kanji_from_id[wk_id], "kanji (#{kanji.id}, #{kanji.wk_id}, #{kanji.character}) is similar to a kanji with a non-existant ID (#{wk_id})") { |v| !v.nil? }
        end
        kanji.similar_kanjis = similar_kanjis
      end

      puts "updates: #{updates}"
      puts "creates: #{creates}"
    end

    def update_performed?(changes, new_radicals: nil, old_radical_ids: nil, old_similar_ids: nil)
      return false if changes.empty?

      puts "kanji #{wk_id}:"
      show_change(changes, "character")
      show_change(changes, "level")
      show_change(changes, "meaning")
      show_change(changes, "meaning_mnemonic", max: 50)
      show_change(changes, "reading")
      show_change(changes, "reading_mnemonic", max: 50)
      show_change(changes, "radicals", no_change: old_radical_ids)
      show_change(changes, "similar_kanjis", no_change: old_similar_ids)
      show_change(changes, "last_updated")

      return false unless permission_granted?
      save!
      self.radicals = new_radicals if new_radicals
      return true
    end
  end
end
