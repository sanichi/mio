module VerbPairHelper
  def verb_pair_search_order_menu(selected)
    opts = %w/group tag/.map { |o| [t("verb_pair.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def verb_pair_group_menu(selected, search: false)
    opts = I18n.t("verb_pair.groups").each_with_index.map { |g,i| [g, i] }
    opts.unshift [search ? t("any") : t("select"), ""]
    options_for_select(opts, selected)
  end

  def verb_pair_transitive_menu(selected)
    vocabs = Vocab.transitive.by_kanji.to_a
    opts = vocabs.map { |v| [v.kanji_reading, v.id] }
    opts.unshift [t("select"), ""]
    options_for_select(opts, selected)
  end

  def verb_pair_intransitive_menu(selected)
    vocabs = Vocab.intransitive.by_kanji.to_a
    opts = vocabs.map { |v| [v.kanji_reading, v.id] }
    opts.unshift [t("select"), ""]
    options_for_select(opts, selected)
  end
end
