module VocabHelper
  def vocab_search_order_menu(selected)
    opts = %w/reading meaning level accent pattern/.map { |g| [t("vocab.#{g}"), g] }
    options_for_select(opts, selected)
  end

  def vocab_level_menu(selected, search: false)
    opts = (Vocab::MIN_LEVEL..Vocab::MAX_LEVEL).to_a.map { |l| [l, l] }
    opts.unshift [search ? t("vocab.any_level") : t("select"), ""]
    options_for_select(opts, selected)
  end

  def vocab_special_search_menu(selected)
    opts = %w/verb adjective/.map { |s| [t("vocab.special.#{s}"), s]}
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end

  def vocab_test_category_menu(selected, search: false)
    opts = VocabTest::CATEGORIES.map { |c| [t("vocab.test.#{c}"), c] }
    opts.unshift [search ? t("vocab.test.any") : t("select"), ""]
    options_for_select(opts, selected)
  end

  def vocab_test_search_order_menu(selected)
    opts = [[t("updated"), "updated"], [t("vocab.level"), "level"], [t("vocab.test.progress_rate"), "progress"], [t("vocab.test.hit_rate"), "hit"]]
    options_for_select(opts, selected)
  end

  def vocab_accent_search_menu(selected)
    max = Vocab.maximum(:accent)
    opts = []
    unless max.nil?
      patterns = Vocab::MIN_PATTERN.upto(Vocab::MAX_PATTERN).map { |p| [ t("vocab.patterns")[p], "#{p}p"] }
      accents = 0.upto(max).map { |a| [ a.to_s, "#{a}a"] }
      opts = patterns.concat(accents)
    end
    opts.unshift [t("none"), "none"] unless opts.empty?
    opts.unshift [t("all"), "all"] unless opts.empty?
    opts.unshift [t("vocab.any_accent"), ""]
    options_for_select(opts, selected)
  end

  def vocab_verb_type_menu(selected)
    opts = %w/godan ichidan suru goichidan/.map { |t| [t("vocab.verb.#{t}"), t] }
    opts.unshift [t("vocab.verb.all"), ""]
    options_for_select(opts, selected)
  end

  def vocab_verb_trans_menu(selected)
    opts = %w/transitive intransitive both neither/.map { |t| [t("vocab.trans.#{t}"), t] }
    opts.unshift [t("vocab.trans.all"), ""]
    options_for_select(opts, selected)
  end

  def similar_kanjis_category_menu(selected, any: false, select: false)
    opts = SimilarKanji::CATEGORIES.map { |c| [t("vocab.similar.kanji.category.#{c}"), c] }
    opts.unshift [t("any"), ""] if any
    opts.unshift [t("select"), ""] if select
    options_for_select(opts, selected)
  end
end
