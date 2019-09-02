module Wk
  class Radical < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Wanikani

    MAX_NAME = 32

    validates :character, length: { is: 1 }, uniqueness: true, allow_nil: true
    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
    validates :mnemonic, presence: true
    validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    scope :by_name,  -> { order(:name) }
    scope :by_level, -> { order(:level, :name) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "level" then by_level
        else              by_name
        end
      if sql = cross_constraint(params[:query], %w{name character})
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
      url = start_url("radical")
      puts "radicals"
      puts "--------"

      while url.present?
        data, url = get_data(url)
        puts "records: #{data.size}"

        data.each do |record|
          raise "radical data is not a hash #{record.class}" unless record&.is_a?(Hash)
          wk_id = record["id"]
          raise "radical doesn't have a positive integer ID (#{wk_id})" unless wk_id.is_a?(Integer) && wk_id > 0
          next if wk_id == 225 # old 225/亼/Roof duplicates 78/宀/Roof
          next if wk_id == 401 # old 401/務/Task duplicates 71/用/Task
          radical = find_or_initialize_by(wk_id: wk_id)

          rdata = record["data"]
          raise "radical #{wk_id} doesn't have a data hash (#{rdata.class})" unless rdata.is_a?(Hash)

          level = rdata["level"]
          raise "radical #{wk_id} doesn't have a valid level (#{level})" unless level.is_a?(Integer) && level > 0 && level <= MAX_LEVEL
          radical.level = level

          meanings = rdata["meanings"]
          raise "radical #{wk_id} (#{level}) doesn't have meanings array (#{meanings.class})" unless meanings.is_a?(Array) && meanings.size > 0
          meanings.keep_if { |meaning| meaning.is_a?(Hash) && meaning["primary"] == true }
          raise "radical #{wk_id} (#{level}) doesn't have any primary meanings" unless meanings.is_a?(Array) && meanings.size > 0
          name = meanings[0]["meaning"]
          raise "radical #{wk_id} (#{level}) first primary meaning is absent" unless name.present?
          radical.name = name

          character = rdata["characters"]
          character = nil unless character.present? && character.length == 1
          radical.character = character

          mnemonic = rdata["meaning_mnemonic"]
          raise "radical #{wk_id} (#{level}, #{name}) doesn't have a mnemonic (#{mnemonic})" unless mnemonic.present?
          radical.mnemonic = mnemonic

          if radical.new_record?
            radical.save!
            creates += 1
          else
            updates += radical.check_update
          end
        end
      end

      puts "updates: #{updates}"
      puts "creates: #{creates}"
    end

    def check_update
      return 0 unless changed?
      changes = self.changes

      puts "radical #{wk_id}:"

      print "  name........ "
      if change = changes["name"]
        puts "#{change.first} => #{change.last}"
      else
        puts name
      end

      print "  character... "
      if change = changes["character"]
        puts "#{change.first} => #{change.last}"
      else
        puts character
      end

      print "  level....... "
      if change = changes["level"]
        puts "#{change.first} => #{change.last}"
      else
        puts level
      end

      print "  mnemonic.... "
      if change = changes["mnemonic"]
        puts "#{change.first.truncate(25)} => #{change.last.truncate(25)}"
      else
        puts mnemonic.truncate(50)
      end

      return 0 unless permission_granted?

      save!
      return 1
    end
  end
end
