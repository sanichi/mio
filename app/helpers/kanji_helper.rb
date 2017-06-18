module KanjiHelper
  def kanji_search_order_menu(selected)
    opts = %w/readings onyomi kunyomi/.map { |o| [t("vocab.#{o}"), o] }
    options_for_select(opts, selected)
  end
end
