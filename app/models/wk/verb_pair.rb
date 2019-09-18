module Wk
  class VerbPair < ApplicationRecord
    include Pageable

    CATEGORIES = %w/eru_aru u_eru eru_u su_ru su_reru asu_eru asu_u irreg passive/
    CAT_ORDER = CATEGORIES.map { |c| "category != '#{c}'" }.join(", ")
    FILTER = /\A(#{Moji.kanji})(#{Moji.hira}+)\z/
    MAX_CATEGORY = 10
    MAX_TAG = 20

    belongs_to :transitive, class_name: "Vocab", foreign_key: :transitive_id
    belongs_to :intransitive, class_name: "Vocab", foreign_key: :intransitive_id

    validates :category, inclusion: { in: CATEGORIES }
    validates :transitive_id, numericality: { integer_only: true, greater_than: 0 }
    validates :intransitive_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: { scope: :transitive_id }

    after_save :set_tag

    scope :by_tag,      -> { order(Arel.sql('tag COLLATE "C"'), Arel.sql(CAT_ORDER)) }
    scope :by_category, -> { order(Arel.sql(CAT_ORDER), Arel.sql('tag COLLATE "C"')) }

    def self.search(params, path, opt={})
      matches =
      case params[:order]
      when "tag" then by_tag
      else            by_category
      end
      matches = matches.where(category: params[:category]) if CATEGORIES.include?(params[:category])
      paginate(matches, params, path, opt)
    end

    def self.update
      trn = Wk::Vocab.where("parts LIKE '%tvb%'").where.not("parts LIKE '%ivb'").where.not("parts LIKE '%srv'").to_a
      int = Wk::Vocab.where("parts LIKE '%ivb%'").where.not("parts LIKE '%tvb'").where.not("parts LIKE '%srv'").to_a
      puts "raw"
      puts "transitives......... #{trn.size}"
      puts "intransitives....... #{int.size}"

      pairs = Hash.new { |h, k| h[k] = { trn: [], int: [] } }
      trn.each do |v|
        if v.characters.match(FILTER)
          pairs[$1][:trn].push [v, $2]
        end
      end
      int.each do |v|
        if v.characters.match(FILTER)
          pairs[$1][:int].push [v, $2]
        end
      end
      pairs.reject! { |k, v| v[:trn].empty? || v[:int].empty? }
      puts "total pairs......... #{pairs.size}"

      numbers = pairs.each_with_object(Hash.new(0)) do |(k,v), n|
        nums = "#{v[:trn].size}-#{v[:int].size}"
        n[nums] += 1
      end
      numbers.keys.sort.each do |k|
        puts "#{k} pairs........... #{numbers[k]}"
      end

      cats = Hash.new(0)
      pairs.each do |k, v|
        trn = v[:trn]
        int = v[:int]
        trn.each do |t|
          tv, th = t
          int.each do |i|
            iv, ih = i
            pair = Wk::VerbPair.find_or_create_by(transitive_id: tv.id, intransitive_id: iv.id)
            pair.category = categorize(th, ih)
            pair.save!
            cats[pair.category] += 1
          end
        end
      end
      cats.keys.sort.each do |c|
        puts "#{c}#{'.' * (7 - c.length)}............. #{cats[c]}"
      end
    end

    def self.categorize(t, i)
      cat = "irreg"
      if t.length == i.length && i.match(/る\z/) # eru_aru su_ru asu_eru
        if t.match(/す\z/) # su_ru asu_eru
          if t.chop == i.chop
            cat = "su_ru"
          elsif t.chop.is_row?("a") && t.chop.shift_row("e") == i.chop
            cat = "asu_eru"
          end
        elsif t.match(/る\z/) # eru_aru
          if t.chop.is_row?("e") && t.chop.shift_row("a") == i.chop
            cat = "eru_aru"
          end
        end
      else # u_eru eru_u su_reru asu_u passive
        if i.match(/る\z/) # u_eru su_reru passive
          if i.chop.is_row?("e") && i.chop.shift_row("u") == t
            cat = "u_eru"
          elsif t.match(/す\z/) && i.match(/れる\z/) && t.chop == i.chop.chop
            cat = "su_reru"
          elsif t.match(/[いえ]る\z/) && t.chop.concat("られる") == i
            cat = "passive"
          elsif t.is_row?("u") && t.shift_row("a").concat("れる") == i
            cat = "passive"
          end
        else # eru_u asu_u
          if t.match(/る\z/) && t.chop.is_row?("e") && t.chop.shift_row("u") == i
            cat = "eru_u"
          elsif t.match(/す\z/) && t.chop.is_row?("a") && t.chop.shift_row("u") == i
            cat = "asu_u"
          end
        end
      end
      cat
    end

    private

    def set_tag
      t = transitive.characters.match(FILTER) ? $2 : "?"
      i = intransitive.characters.match(FILTER) ? $2 : "?"
      update_column :tag, "#{t}→#{i}"
    end
  end
end
