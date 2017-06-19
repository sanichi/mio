module KanjiHelper
  def kanji_search_order_menu(selected)
    opts = %w/onyomi kunyomi/.map { |o| [t("vocab.#{o}"), o] }
    opts.unshift [t("total"), "total"]
    options_for_select(opts, selected)
  end

  def kanji_search_level_menu(selected)
    opts = (Vocab::MIN_LEVEL..Vocab::MAX_LEVEL).to_a.map { |l| [l, l] }
    opts.unshift [t("vocab.any_level"), ""]
    options_for_select(opts, selected)
  end
end
