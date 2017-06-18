module ReadingHelper
  def reading_search_order_menu(selected)
    opts = %w/onyomi kunyomi kana/.map { |o| [t("vocab.#{o}"), o] }
    opts.unshift [t("total"), "total"]
    options_for_select(opts, selected)
  end
end
