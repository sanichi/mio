module Wk
  class Reading < ActiveRecord::Base
    include Accentable
    include Vocabable
    include Wanikani

    before_validation :set_accent_pattern

    validates :accent_position, numericality: { integer_only: true, greater_than_or_equal_to: MIN_ACCENT_POSITION, less_than_or_equal_to: MAX_CHARACTERS }, allow_nil: true
    validates :accent_pattern, numericality: { integer_only: true, greater_than_or_equal_to: MIN_ACCENT_PATTERN, less_than_or_equal_to: MAX_ACCENT_PATTERN }, allow_nil: true
    validates :characters, presence: true, length: { maximum: MAX_CHARACTERS }

    belongs_to :vocab
    has_many :audios, as: :audible, dependent: :destroy

    default_scope { order(primary: :desc) }

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

          audios = check(data["pronunciation_audios"], "#{context} doesn't have an audios array") { |v| v.is_a?(Array) }
          wk_audios = Hash.new { |h, k| h[k] = [] }
          audios.each do |a|
            check(a, "#{context} has an invalid audio") { |v| v.is_a?(Hash) && v["url"].is_a?(String) && v["url"].starts_with?(Audio::DEFAULT_BASE) && v["metadata"].is_a?(Hash) && v["content_type"].is_a?(String) && v["content_type"].present? && v["metadata"]["pronunciation"].is_a?(String) }
            pn = a["metadata"]["pronunciation"]
            if wk_readings.has_key?(pn)
              if a["content_type"] == "audio/mpeg"
                wk_audios[pn].push(a["url"].delete_prefix(Audio::DEFAULT_BASE))
              end
            else
              known_problems = [
                3368, # 球
                4937, # 株式会社
                4946, # 河豚
                5192, # 菓子屋
                5624, # 否
                6523, # 〜畑
                7086, # 下唇
                7087, # 上唇
                7551, # 連中
                8038, # 蓮根
              ]
              check(wk_id, "unexpected problem with readings for #{wk_id}") { |v| known_problems.include?(v) }
              stats["skipped known problems"] += 1
            end
          end
          db_readings.each do | characters, reading |
            wk_audios[characters].each do |file|
              db_audio = Audio.find_by(audible_id: reading.id, audible_type: "Wk::Reading", file: file)
              if db_audio
                stats["matched audios"] += 1
              else
                reading.audios << Audio.create!(audible_id: reading.id, audible_type: "Wk::Reading", file: file)
                # reading.audios.create!(file: file)
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
        key = "DB vocabs no longer in WK"
        stats[key] = old_wk_ids.size
        extra[key] = "(#{old_wk_ids.sort.join(',')})".truncate(max_extra)
      end

      puts "stats:"
      stats.sort_by { |k, v| v }.reverse.each do |k, v|
        puts "  %s%s %s %s" % [k, "." * (25 - k.length), v, extra[k]]
      end
    end
  end
end
