module RadicalHelper
  def radical_search_order_menu(selected)
    opts = %w/meaning symbol/.map { |o| [t("vocab.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def radical_search_level_menu(selected)
    opts = (Vocab::MIN_LEVEL..Vocab::MAX_LEVEL).to_a.map { |l| [l, l] }
    opts.unshift [t("vocab.any_level"), ""]
    options_for_select(opts, selected)
  end
end
