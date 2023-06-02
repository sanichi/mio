module Wk
  class Kana < ApplicationRecord
    include Constrainable
    include Pageable
    include Remarkable
    include Vocabable
    include Wanikani

    before_validation :clean_up

    validates :characters, presence: true, length: { maximum: Wk::Vocab::MAX_CHARACTERS }, uniqueness: true
    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
    validates :meaning, presence: true, length: { maximum: Wk::Vocab::MAX_MEANING }
    validates :meaning_mnemonic, presence: true
    validates :parts, presence: true, length: { maximum: Wk::Vocab::MAX_PARTS }
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    scope :by_characters,   -> { order(Arel.sql('characters COLLATE "C"')) }
    scope :by_level,        -> { order(:level, Arel.sql('characters COLLATE "C"')) }
    scope :by_last_updated, -> { order(last_updated: :desc, level: :asc) }

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

          if kana.new_record?
            kana.save!
            count[:creates] += 1
          else
            old_wk_ids.delete(wk_id)
            changes = kana.changes
            count[:updates] += 1 if kana.update_performed?(changes)
          end
          count[:total] += 1
        end
      end

      puts "total..... #{count[:total]}"
      puts "hidden.... #{count[:hidden]}"
      puts "updates... #{count[:updates]}"
      puts "creates... #{count[:creates]}"

      if days.nil?
        puts "DB vocabs no longer in WK #{old_wk_ids.size}: #{old_wk_ids.sort.join(',')}"
      end
    end

    def update_performed?(changes)
      return false if changes.empty?

      puts "kana #{wk_id}:"
      show_change(changes, "hidden")
      show_change(changes, "last_updated")
      show_change(changes, "level")
      show_change(changes, "meaning")
      show_change(changes, "meaning_mnemonic", max: 50)
      show_change(changes, "parts")

      ask = changes.size == 1 && changes.has_key?("last_updated") ? false : true
      return false if ask && !permission_granted?

      save!
      return true
    end

    private

    def clean_up
      self.notes = nil unless notes.present?
    end
  end
end
