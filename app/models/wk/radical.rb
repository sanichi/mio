module Wk
  class Radical < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Wanikani

    MAX_NAME = 32

    has_and_belongs_to_many :kanjis

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
        when "name"         then by_name
        else                     by_level
        end
      if sql = cross_constraint(params[:rquery], %w{name character})
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

    def self.update(days=nil)
      count = Hash.new(0)

      url, since = start_url("radical", days)
      puts
      puts "radicals since #{since}"
      puts "-------------------------"

      while url.present?
        subjects, url = get_subjects(url)
        puts "subjects.. #{subjects.size}"

        subjects.each do |subject|
          check(subject, "radical subject is not a hash (#{subject.class})") { |v| v.is_a?(Hash) }

          wk_id = check(subject["id"], "radical ID is not a positive integer ID") { |v| v.is_a?(Integer) && v > 0 }

          radical = find_or_initialize_by(wk_id: wk_id)
          context = "radical (#{wk_id})"

          last_updated =
            begin
              Date.parse(subject["data_updated_at"].to_s)
            rescue ArgumentError
              nil
            end
          radical.last_updated = check(last_updated, "#{context} has no valid last update date") { |v| v.is_a?(Date) }

          data = check(subject["data"], "#{context} doesn't have a data hash") { |v| v.is_a?(Hash) }

          check(data, "#{context} doesn't have a hidden field") { |v| v.has_key?("hidden_at") }
          radical.hidden = !!data["hidden_at"]
          count[:hidden] += 1 if radical.hidden
          meanings = check(data["meanings"], "#{context} doesn't have a meanings array") { |v| v.is_a?(Array) && v.size > 0 }
          meanings.keep_if { |m| m.is_a?(Hash) && m["primary"] == true }
          check(meanings, "#{context} doesn't have any primary meanings") { |v| v.size > 0 }
          name = check(meanings[0]["meaning"], "#{context} first meaning has no name") { |v| v.is_a?(String) && v.present? }
          name += "-h" if radical.hidden # otherwise name is not unique for at least one hidden radical
          radical.name = check(name, "#{context} name is too long (#{name.length})") { |v| v.length <= MAX_NAME }
          context[-1,1] = ", #{radical.name})"

          # some radicals have no characters so we allow that
          character = data["characters"]
          character = nil unless character.present? && character.length == 1
          radical.character = character
          context[-1,1] = ", #{radical.character || 'none'})"

          radical.level = check(data["level"], "#{context} doesn't have a valid level") { |v| v.is_a?(Integer) && v > 0 && v <= MAX_LEVEL }
          context[-1,1] = ", #{radical.level})"

          radical.mnemonic = check(data["meaning_mnemonic"], "#{context} doesn't have a mnemonic") { |v| v.is_a?(String) && v.present? }

          if radical.new_record?
            radical.save!
            count[:creates] += 1
          else
            count[:updates] += 1 if radical.update_performed?
          end
          count[:total] += 1
        end
      end

      puts "total..... #{count[:total]}"
      puts "hidden.... #{count[:hidden]}"
      puts "updates... #{count[:updates]}"
      puts "creates... #{count[:creates]}"
    end

    def character_name(linked: false)
      if character
        kanji = Kanji.find_by(character: character) if linked
        if kanji
          %Q{<a href="/wk/kanjis/#{kanji.id}">#{character}</a>-#{name}}.html_safe
        else
          "#{character}-#{name}"
        end
      else
        name
      end
    end

    def update_performed?
      return false unless changed?

      changes = self.changes

      puts "radical #{wk_id}:"
      show_change(changes, "hidden")
      show_change(changes, "name")
      show_change(changes, "character")
      show_change(changes, "level")
      show_change(changes, "mnemonic", max: 50)
      show_change(changes, "last_updated")

      ask = changes.size == 1 && changes.has_key?("last_updated") ? false : true
      return false if ask && !permission_granted?

      save!
      return true
    end
  end
end
