module VocabHelper
  def vocab_search_order_menu(selected)
    opts = %w/reading meaning level/.map { |g| [t("vocab.#{g}"), g] }
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
end
