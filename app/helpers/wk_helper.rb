module WkHelper
  def wk_level_menu(selected)
    opts = (0..Wk::MAX_LEVEL).to_a.map { |l| [l, l] }
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end

  def wk_radical_order_menu(selected)
    opts = [[t("wk.level"), "level"], [t("wk.radical.name"), "name"], [t("wk.last_updated"), "last_updated"]]
    options_for_select(opts, selected)
  end

  def wk_kanji_order_menu(selected)
    opts = %w/level character meaning reading last_updated/.map { |i| [t("wk.#{i}"), i] }
    options_for_select(opts, selected)
  end

  def wk_vocab_order_menu(selected)
    opts = %w/level last_updated/.map { |i| [t("wk.#{i}"), i] }
    opts.push [t("wk.vocab.characters"), "characters"]
    options_for_select(opts, selected)
  end
end
