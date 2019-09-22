module Wk
  class VerbPair < ApplicationRecord
    include Constrainable
    include Pageable

    CATEGORIES = %w/eru_aru u_eru eru_u su_ru su_reru asu_eru asu_u irreg passive/
    CAT_ORDER = CATEGORIES.map { |c| "category != '#{c}'" }.join(", ")
    FILTER = /\A(#{Moji.kanji})(#{Moji.hira}+)\z/
    MAX_CATEGORY = 10
    MAX_SUFFIX = 6
    MAX_TAG = 500
    TAG_SEP = "|"

    belongs_to :transitive, class_name: "Vocab", foreign_key: :transitive_id
    belongs_to :intransitive, class_name: "Vocab", foreign_key: :intransitive_id

    validates :category, inclusion: { in: CATEGORIES }
    validates :intransitive_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: { scope: :transitive_id }
    validates :transitive_id, numericality: { integer_only: true, greater_than: 0 }
    validates :transitive_suffix, :intransitive_suffix, presence: true, length: { maximum: MAX_SUFFIX }

    after_save :set_tag

    scope :by_group_tsuffix, -> { order(Arel.sql(CAT_ORDER), Arel.sql('transitive_suffix COLLATE "C"')) }
    scope :by_group_isuffix, -> { order(Arel.sql(CAT_ORDER), Arel.sql('intransitive_suffix COLLATE "C"')) }
    scope :by_isuffix_group, -> { order(Arel.sql('intransitive_suffix COLLATE "C"'), Arel.sql(CAT_ORDER)) }
    scope :by_tsuffix_group, -> { order(Arel.sql('transitive_suffix COLLATE "C"'), Arel.sql(CAT_ORDER)) }
    scope :by_treading,      -> { includes(:transitive).order(Arel.sql('wk_vocabs.reading COLLATE "C"')) }
    scope :by_ireading,      -> { includes(:intransitive).order(Arel.sql('wk_vocabs.reading COLLATE "C"')) }

    def self.search(params, path, opt={})
      matches =
      case params[:order]
      when "group_isuffix" then by_group_isuffix
      when "group_tsuffix" then by_group_tsuffix
      when "isuffix_group" then by_isuffix_group
      when "tsuffix_group" then by_tsuffix_group
      when "treading"      then by_treading
      when "ireading"      then by_ireading
      else                      by_tsuffix_group
      end
      if sql = cross_constraint(params[:query], %w{tag})
        matches = matches.where(sql)
      end
      matches = matches.where(category: params[:category]) if CATEGORIES.include?(params[:category])
      paginate(matches, params, path, opt)
    end

    def okay?
      transitive.reading.delete_suffix(transitive_suffix) == intransitive.reading.delete_suffix(intransitive_suffix)
    end

    def suffixes
      "#{transitive_suffix}・#{intransitive_suffix}"
    end

    def self.update
      count = Wk::VerbPair.count
      Wk::VerbPair.delete_all
      puts "old pairs deleted... #{count}"

      trn = Wk::Vocab.where("parts LIKE '%tvb%'").where.not("parts LIKE '%ivb%'").where.not("parts LIKE '%srv%'").to_a
      int = Wk::Vocab.where("parts LIKE '%ivb%'").where.not("parts LIKE '%tvb%'").where.not("parts LIKE '%srv%'").to_a
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
        ts = v[:trn]
        is = v[:int]
        ts.each do |t|
          tv, th = t
          is.each do |i|
            iv, ih = i
            pair = Wk::VerbPair.create(transitive: tv, intransitive: iv, transitive_suffix: th, intransitive_suffix: ih)
            if pair.okay?
              pair.categorize!
              pair.save!
              cats[pair.category] += 1
            else
              cats["rejected"] += 1
            end
          end
        end
      end
      cats.keys.sort.each do |c|
        puts "#{c}#{'.' * (9 - c.length)}........... #{cats[c]}"
      end
    end

    def categorize!
      cat = "irreg"
      t = transitive_suffix
      i = intransitive_suffix
      if t.length == i.length && i.match(/る\z/) # eru_aru su_ru asu_eru
        if t.match(/す\z/) # su_ru asu_eru
          if t.chop == i.chop
            cat = "su_ru"
          elsif t.chop.is_row?("a") && t.chop.shift_row("e") == i.chop
            cat = "asu_eru"
          elsif t[-2] == "や" && i[-2] == "え"
            cat = "asu_eru"
          end
        elsif t.match(/る\z/) # eru_aru
          if t.chop.is_row?("e") && t.chop.shift_row("a") == i.chop
            cat = "eru_aru"
          elsif t[-2] == "え" && i[-2] == "わ"
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
      self.category = cat
    end

    private

    def set_tag
      update_column :tag, [transitive.characters, intransitive.characters, transitive.reading, intransitive.reading, transitive.meaning, intransitive.meaning].join(TAG_SEP)
    end
  end
end
