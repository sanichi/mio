module VerbHelper
  def verb_search_order_menu(selected)
    opts = %w/reading meaning/.map { |g| [t("vocab.#{g}"), g] }
    options_for_select(opts, selected)
  end

  def verb_category_menu(selected, search: false)
    opts = Verb::CATEGORIES.map { |c| [t("verb.categories.#{c}"), c] }
    opts.unshift [t(search ? "verb.any_category" : "select"), ""]
    options_for_select(opts, selected)
  end

  def verb_transitivity_search_menu(selected)
    opts = [[t("verb.any_transitivity"), ""], [t("verb.transitive"), "yes"], [t("verb.intransitive"), "no"]]
    opts.unshift
    options_for_select(opts, selected)
  end
end
