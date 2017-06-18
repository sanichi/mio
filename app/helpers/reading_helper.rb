module ReadingHelper
  def reading_search_order_menu(selected)
    opts = %w/kanjis onyomi kunyomi/.map { |o| [t("vocab.#{o}"), o] }
    options_for_select(opts, selected)
  end
end
