module VocabHelper
  def vocab_search_order_menu(selected)
    opts = %w/reading meaning level/.map { |g| [t("vocab.#{g}"), g] }
    options_for_select(opts, selected)
  end

  def vocab_level_menu(selected, search: false)
    opts = (Vocab::MIN_LEVEL..Vocab::MAX_LEVEL).to_a.map { |l| [l, l] }
    opts.unshift [search ? t("vocab.any_level") : t("select"), ""]
    options_for_select(opts, selected)
  end

  def vocab_special_search_menu(selected)
    opts = %w/verb/.map { |s| [t("vocab.special.#{s}"), s]}
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
end
