module GrammarHelper
  def grammar_order_menu(selected)
    opts = %w/title level/.map { |o| [t("grammar.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def grammar_level_menu(selected)
    opts = Grammar::LEVELS.map { |l| [l.to_s, l] }
    opts.unshift [t("all"), 0]
    options_for_select(opts, selected)
  end
end
