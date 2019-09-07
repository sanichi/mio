module Wk
  class Vocab < ActiveRecord::Base
    include Constrainable
    include Pageable
    include Wanikani

    MAX_CHARACTERS = 24

    validates :level, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_LEVEL }
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
      if sql = cross_constraint(params[:vquery], %w{characters})
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
      url = start_url("vocabulary")
      max = 0

      puts "vocabs"
      puts "------"

      while url.present? do
        subjects, url = get_subjects(url)
        puts "subjects: #{subjects.size}"

        # updates and creates that don't need all vocab present
        subjects.each do |subject|
          check(subject, "vocab subject is not a hash #{subject.class}") { |v| v.is_a?(Hash) }

          wk_id = check(subject["id"], "vocab ID is not a positive integer ID") { |v| v.is_a?(Integer) && v > 0 }
          vocab = find_or_initialize_by(wk_id: wk_id)
          context = "vocab (#{wk_id})"

          last_updated =
            begin
              Date.parse(subject["data_updated_at"].to_s)
            rescue ArgumentError
              nil
            end
          vocab.last_updated = check(last_updated, "#{context} has no valid last update date") { |v| v.is_a?(Date) }

          data = check(subject["data"], "#{context} doesn't have a data hash") { |v| v.is_a?(Hash) }

          vocab.characters = check(data["characters"], "#{context} doesn't have valid characters") { |v| v.is_a?(String) && v.present? && v.length <= MAX_CHARACTERS }
          context[-1,1] = ", #{vocab.characters})"

          vocab.level = check(data["level"], "#{context} doesn't have a valid level") { |v| v.is_a?(Integer) && v > 0 && v <= MAX_LEVEL }
          context[-1,1] = ", #{vocab.level})"

          if vocab.new_record?
            vocab.save!
            creates += 1
          else
            changes = vocab.changes
            updates += 1 if vocab.update_performed?(changes)
          end
        end
      end

      puts "updates: #{updates}"
      puts "creates: #{creates}"
      puts "max: #{max}"
    end

    def update_performed?(changes)
      return false if changes.empty?

      puts "vocab #{wk_id}:"
      show_change(changes, "level")
      show_change(changes, "last_updated")

      return false unless permission_granted?
      save!
      return true
    end
  end
end
