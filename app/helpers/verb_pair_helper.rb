module VerbPairHelper
  def verb_pair_category_menu(selected, search: false)
    opts = VerbPair::CATEGORIES.map { |c| [t("verb_pair.categories.#{c}"), c] }
    opts.unshift [search ? t("any") : t("select"), ""]
    options_for_select(opts, selected)
  end

  def verb_pair_transitive_menu(selected)
    vocabs = Vocab.by_kanji.where("category ILIKE '%verb%' AND category NOT ILIKE '%intransitive%'").to_a
    opts = vocabs.map { |v| [v.kanji_reading, v.id] }
    opts.unshift [t("select"), ""]
    options_for_select(opts, selected)
  end

  def verb_pair_intransitive_menu(selected)
    vocabs = Vocab.by_kanji.where("category ILIKE '%verb%' AND category ILIKE '%intransitive%'").to_a
    opts = vocabs.map { |v| [v.kanji_reading, v.id] }
    opts.unshift [t("select"), ""]
    options_for_select(opts, selected)
  end
end
