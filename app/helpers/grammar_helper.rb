module GrammarHelper
  def grammar_order_menu(selected)
    opts = %w/updated ref title level/.map { |o| [t("grammar.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def grammar_level_menu(selected)
    opts = Grammar::LEVELS.map { |l| [l.to_s, l] }
    opts.unshift [t("all"), 0]
    options_for_select(opts, selected)
  end

  def grammar_group_menu(groups)
    opts = groups.map { |g| [g.title, g.id] }
    options_for_select(opts)
  end
end
