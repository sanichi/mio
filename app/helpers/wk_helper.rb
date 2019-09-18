module WkHelper
  def wk_level_menu(selected)
    opts = (0..Wk::MAX_LEVEL).to_a.map { |l| [l, l] }
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end

  def wk_radical_order_menu(selected)
    opts = %w/level last_updated/.map { |i| [t("wk.#{i}"), i] }
    opts.insert 1, [t("wk.radical.name"), "name"]
    options_for_select(opts, selected)
  end

  def wk_kanji_order_menu(selected)
    opts = %w/level character meaning reading last_updated/.map { |i| [t("wk.#{i}"), i] }
    options_for_select(opts, selected)
  end

  def wk_vocab_order_menu(selected)
    opts = %w/level reading last_updated/.map { |i| [t("wk.#{i}"), i] }
    opts.insert 1, [t("wk.vocab.characters"), "characters"]
    options_for_select(opts, selected)
  end

  def wk_vocab_parts_menu(selected)
    opts = t("wk.parts").map { |k, v| [v, k] }
    options_for_select(opts, selected)
  end

  def wk_verb_pair_category_menu(selected)
    opts = Wk::VerbPair::CATEGORIES.map { |c| [t("wk.verb_pair.categories.#{c}", locale: "jp"), c] }
    opts.unshift [t("any", locale: "jp"), ""]
    options_for_select(opts, selected)
  end

  def wk_verb_pair_order_menu(selected)
    opts = %w/tag category/.map { |i| [t("wk.verb_pair.#{i}"), i] }
    options_for_select(opts, selected)
  end
end
