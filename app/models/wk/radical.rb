module Wk
  class Radical < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Wanikani

    MAX_NAME = 32

    has_and_belongs_to_many :kanjis

    before_validation :truncate

    validates :character, length: { is: 1 }, uniqueness: true, allow_nil: true
    validates :last_updated, presence: true
    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
    validates :mnemonic, presence: true
    validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    scope :by_name,         -> { order(:name) }
    scope :by_level,        -> { order(:level, :name) }
    scope :by_last_updated, -> { order(last_updated: :desc, name: :asc) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "last_updated" then by_last_updated
        when "level"        then by_level
        else                     by_name
        end
      if sql = cross_constraint(params[:query], %w{name character})
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
      url = start_url("radical")
      puts "radicals"
      puts "--------"

      while url.present?
        data, url = get_data(url)
        puts "records: #{data.size}"

        data.each do |record|
          check(record, "radical record is not a hash (#{record.class})") { |v| v.is_a?(Hash) }

          wk_id = check(record["id"], "radical ID is not a positive integer ID") { |v| v.is_a?(Integer) && v > 0 }

          radical = find_or_initialize_by(wk_id: wk_id)
          subject = "radical (#{wk_id})"

          last_updated =
            begin
              Date.parse(record["data_updated_at"].to_s)
            rescue ArgumentError
              nil
            end
          radical.last_updated = check(last_updated, "#{subject} has no valid last update date") { |v| v.is_a?(Date) }

          rdata = check(record["data"], "#{subject} doesn't have a data hash") { |v| v.is_a?(Hash) }

          meanings = check(rdata["meanings"], "#{subject} doesn't have a meanings array") { |v| v.is_a?(Array) && v.size > 0 }
          meanings.keep_if { |m| m.is_a?(Hash) && m["primary"] == true }
          check(meanings, "#{subject} doesn't have any primary meanings") { |v| v.size > 0 }
          radical.name = check(meanings[0]["meaning"], "#{subject} first meaning has no name") { |v| v.is_a?(String) && v.present? }
          subject[-1,1] = ", #{radical.name})"

          # some radicals have no characters so we allow that
          character = rdata["characters"]
          character = nil unless character.present? && character.length == 1
          radical.character = character
          subject[-1,1] = ", #{radical.character || 'none'})"

          radical.level = check(rdata["level"], "#{subject} doesn't have a valid level") { |v| v.is_a?(Integer) && v > 0 && v <= MAX_LEVEL }
          subject[-1,1] = ", #{radical.level})"

          radical.mnemonic = check(rdata["meaning_mnemonic"], "#{subject} doesn't have a mnemonic") { |v| v.is_a?(String) && v.present? }

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

    def character_name
      "#{character}#{character.present? ? '-' : ''}#{name}"
    end

    def check_update
      return 0 unless changed?

      changes = self.changes

      puts "radical #{wk_id}:"
      show_change(changes, "name")
      show_change(changes, "character")
      show_change(changes, "level")
      show_change(changes, "mnemonic", max: 50)
      show_change(changes, "last_updated")

      return 0 unless permission_granted?
      save!
      return 1
    end

    private

    def truncate
      self.name = name&.truncate(MAX_NAME)
    end
  end
end
