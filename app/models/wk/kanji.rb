module Wk
  class Kanji < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Wanikani

    MAX_MEANING = 128
    MAX_READING = 128
    IMAGES = Rails.root + "public" + "images"
    PDFS = Rails.root + "public" + "pdf"

    has_and_belongs_to_many :radicals
    has_and_belongs_to_many :similar_kanjis, class_name: "Wk::Kanji", association_foreign_key: "similar_id"

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
    scope :by_reading,      -> { order(Arel.sql('reading COLLATE "C"'), :level) }
    scope :by_last_updated, -> { order(last_updated: :desc, level: :asc) }

    def self.search(params, path, opt={})
      matches = radical_search(params[:kquery])
      if !matches
        if sql = cross_constraint(params[:kquery], %w{character meaning reading})
          matches = where(sql)
        else
          matches = all
        end
      end
      if sql = numerical_constraint(params[:id], :wk_id)
        matches = matches.where(sql)
      end
      if (level = params[:level].to_i) > 0
        matches = matches.where(level: level)
      end
      if params[:image] == "kayo"
        matches = matches.where(character: images)
      end
      matches =
        case params[:order]
        when "character"    then matches.by_character
        when "last_updated" then matches.by_last_updated
        when "meaning"      then matches.by_meaning
        when "reading"      then matches.by_reading
        else                     matches.by_level
        end
      paginate(matches, params, path, opt)
    end

    def self.similar(params, path, opt={})
      message = add_or_remove_similar(params)
      owner =
        case params[:owner]
        when "wk"
          "= 't'"
        when "either"
          "IN ('t', 'f')"
        else
          "= 'f'"
        end
      sql = "SELECT DISTINCT kanji_id FROM wk_kanjis_kanjis WHERE wk #{owner}"
      matches = where("id IN (#{sql})").includes(:similar_kanjis).order(:reading)
      if sql = cross_constraint(params[:query], %w{character meaning reading})
        matches = matches.where(sql)
      end
      [paginate(matches, params, path, opt), message]
    end

    def self.add_or_remove_similar(params)
      # See if the query matches a special pattern which means to add or delete some similarities.
      return unless params[:query]&.match(/\A([-+ー＋])([^\p{ASCII}]+)\z/)

      # Analyse what we just matched.
      adding = $1 == "+" || $1 == "＋"
      messages = []
      kanjis = $2.split("").map do |c|
        messages.push "#{c} not found" unless k = find_by(character: c)
        k
      end
      return messages.join(", ") unless messages.empty?
      return "need at least 2 kanjis" unless kanjis.size > 1
      params[:query] = "(#{kanjis.map(&:character).join('|')})"

      # Take each pair from the list.
      kanjis.combination(2).each do |k1,k2|
        pair = "#{k1.character}-#{k2.character}"
        if adding
          if k1.similar_kanjis.include?(k2) && k2.similar_kanjis.include?(k1)
            # We already have it.
            messages.push "#{pair} already exists"
          else
            # Needs creating.
            ActiveRecord::Base.connection.execute("INSERT INTO wk_kanjis_kanjis VALUES (#{k1.id}, #{k2.id}, 'f')") unless k1.similar_kanjis.include?(k2)
            ActiveRecord::Base.connection.execute("INSERT INTO wk_kanjis_kanjis VALUES (#{k2.id}, #{k1.id}, 'f')") unless k2.similar_kanjis.include?(k1)
            messages.push "#{pair} created"
          end
        else
          if !k1.similar_kanjis.include?(k2) && !k2.similar_kanjis.include?(k1)
            # We don't already have it.
            messages.push "#{pair} not found"
          else
            # Delete both links if they are custom (wk attribute false).
            r1 = ActiveRecord::Base.connection.execute("DELETE FROM wk_kanjis_kanjis WHERE kanji_id = #{k1.id} AND similar_id = #{k2.id} AND wk = 'f'") if k1.similar_kanjis.include?(k2)
            r2 = ActiveRecord::Base.connection.execute("DELETE FROM wk_kanjis_kanjis WHERE kanji_id = #{k2.id} AND similar_id = #{k1.id} AND wk = 'f'") if k2.similar_kanjis.include?(k1)
            if r1&.cmd_tuples == 0 || r2&.cmd_tuples == 0
              messages.push "#{pair} undeleteable"
            else
              messages.push "#{pair} deleted"
            end
          end
        end
      end

      # Return the joined up messages.
      messages.join(", ")
    end

    def self.radical_search(kquery)
      names = kquery.to_s.split(" ")
      return nil if names.empty?
      return nil unless names.map{|n| n.match?(/\A[A-Za-z]+\z/)}.all?
      return nil unless names.first.match?(/\A[A-Z][A-Za-z]+\z/)
      relation = joins(:radicals)
      ids = nil
      names.each do |n|
        nids = relation.where("wk_radicals.name ILIKE '%#{n}%'").pluck(:id)
        if ids.nil?
          ids = nids
        else
          ids = ids.intersection(nids)
        end
        last if ids.empty?
      end
      where(id: ids)
    end

    def linked_character
      radical = Radical.find_by(character: character)
      if radical
        %Q{<a href="/wk/radicals/#{radical.id}">#{character}</a>}.html_safe
      else
        character
      end
    end

    def to_markdown(display: nil)
      "[#{display || character}](/wk/kanjis/#{id})"
    end

    def obs_name() = character + " " + meaning

    def image_path
      %w/jpg gif/.each do |type|
        file = "#{character}.#{type}"
        path = IMAGES + file
        return "/images/#{file}" if path.file?
      end
      nil
    end

    def pdf_path
      file = "#{character}.pdf"
      path = PDFS + file
      return unless path.file?
      "/pdf/#{file}"
    end

    def self.images
      IMAGES.glob("?.jpg").map(&:to_s).map{|n| n[-5]}
    end

    def self.update(days=nil)
      count = Hash.new(0)
      new_similarities = {}
      radical_from_id = Radical.all.each_with_object({}) { |r, h| h[r.wk_id] = r }

      url, since = start_url("kanji", days)
      puts
      puts "kanjis since #{since}"
      puts "-----------------------"

      while url.present? do
        subjects, url = get_subjects(url)
        puts "subjects.. #{subjects.size}"

        # updates and creates that don't need all kanji present
        subjects.each do |subject|
          check(subject, "kanji subject is not a hash #{subject.class}") { |v| v.is_a?(Hash) }

          wk_id = check(subject["id"], "kanji ID is not a positive integer ID") { |v| v.is_a?(Integer) && v > 0 }
          kanji = find_or_initialize_by(wk_id: wk_id)
          context = "kanji (#{wk_id})"

          last_updated =
            begin
              Date.parse(subject["data_updated_at"].to_s)
            rescue ArgumentError
              nil
            end
          kanji.last_updated = check(last_updated, "#{context} has no valid last update date") { |v| v.is_a?(Date) }

          data = check(subject["data"], "#{context} doesn't have a data hash") { |v| v.is_a?(Hash) }

          check(data, "#{context} doesn't have a hidden field") { |v| v.has_key?("hidden_at") }
          kanji.hidden = !!data["hidden_at"]
          count[:hidden] += 1 if kanji.hidden

          kanji.character = check(data["characters"], "#{context} doesn't have a character") { |v| v.is_a?(String) && v.length == 1 }
          context[-1,1] = ", #{kanji.character})"

          kanji.level = check(data["level"], "#{context} doesn't have a valid level") { |v| v.is_a?(Integer) && v > 0 && v <= MAX_LEVEL }
          context[-1,1] = ", #{kanji.level})"

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
          kanji.meaning = check(meaning, "#{context} meaning is too long (#{meaning.length})") { |v| v.length <= MAX_MEANING }
          context[-1,1] = ", #{kanji.meaning})"

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
          kanji.reading = check(reading, "#{context} reading is too long (#{reading.length})") { |v| v.length <= MAX_READING }
          context[-1,1] = ", #{kanji.reading})"

          meaning_mnemonic = check(data["meaning_mnemonic"], "#{context} doesn't have a meaning mnemonic") { |v| v.is_a?(String) && v.present? }
          meaning_hint = data["meaning_hint"]
          kanji.meaning_mnemonic = meaning_hint ? "<p>#{meaning_mnemonic}</p><p>#{meaning_hint}</p>" : meaning_mnemonic

          reading_mnemonic = check(data["reading_mnemonic"], "#{context} doesn't have a reading mnemonic") { |v| v.is_a?(String) && v.present? }
          reading_hint = data["reading_hint"]
          kanji.reading_mnemonic = reading_hint ? "<p>#{reading_mnemonic}</p><p>#{reading_hint}</p>" : reading_mnemonic

          component_ids = check(data["component_subject_ids"], "#{context} doesn't have a radicals array") { |v| v.is_a?(Array) && v.size > 0 }
          old_radical_ids = kanji.new_record? ? [] : kanji.radicals.pluck(:wk_id)
          new_radical_ids = component_ids.map do |v|
            check(v, "#{context} has invalid radical ID (#{v}) }") { |v| radical_from_id.has_key?(v) }
          end
          new_radical_ids.uniq! # just in case, although in this case (unlike similar kanjis) there seem to be no duplicates
          same_radicals = new_radical_ids.size == old_radical_ids.size && new_radical_ids.to_set == old_radical_ids.to_set
          radicals = component_ids.map { |wk_id| radical_from_id[wk_id] }

          old_similar_ids = kanji.new_record? ? [] : kanji.similar_kanjis.pluck(:wk_id)
          new_similar_ids = data["visually_similar_subject_ids"]
          new_similar_ids = [] unless new_similar_ids.is_a?(Array) && new_similar_ids.all? { |id| id.is_a?(Integer) && id > 0 }
          new_similar_ids.uniq! # sadly, WK data is not always unique
          new_similar_ids.reject! { |id| id == wk_id } # don't allow self-similarity just in case
          same_similar_kanjis = new_similar_ids.size == old_similar_ids.size && new_similar_ids.to_set == old_similar_ids.to_set

          if kanji.new_record?
            kanji.save!
            kanji.radicals = radicals
            count[:creates] += 1
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
            if kanji.update_performed?(changes, **options)
              count[:updates] += 1
            else
              # if we don't update the other attributes, don't update similar kanjis either
              same_similar_kanjis = true
            end
          end
          count[:total] += 1

          # these updates will be done later after all kanji are in place
          new_similarities[kanji] = new_similar_ids unless same_similar_kanjis
        end
      end

      # updates that need all kanji present
      kanji_from_id = Kanji.all.each_with_object({}) { |k, h| h[k.wk_id] = k }
      new_similarities.each do |kanji, similar_ids|
        similar_kanjis = similar_ids.map do |wk_id|
          check(kanji_from_id[wk_id], "kanji (#{kanji.id}, #{kanji.wk_id}, #{kanji.character}) is similar to a kanji with a non-existant ID (#{wk_id})") { |v| !v.nil? }
        end
        kanji.similar_kanjis = similar_kanjis
      end

      puts "total..... #{count[:total]}"
      puts "hidden.... #{count[:hidden]}"
      puts "updates... #{count[:updates]}"
      puts "creates... #{count[:creates]}"
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

      ask = changes.size == 1 && changes.has_key?("last_updated") ? false : true
      return false if ask && !permission_granted?

      save!
      self.radicals = new_radicals if new_radicals
      return true
    end
  end
end
