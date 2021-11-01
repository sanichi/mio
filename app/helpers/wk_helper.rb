module WkHelper
  def wk_level_menu(selected)
    opts = (1..Wk::MAX_LEVEL).to_a.map { |l| [l, l] }
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end

  def wk_radical_order_menu(selected)
    opts = %w/level last_updated/.map { |i| [t("wk.#{i}"), i] }
    opts.insert 1, [t("wk.radical.name"), "name"]
    options_for_select(opts, selected)
  end

  def wk_kanji_order_menu(selected)
    opts = %w/level character meaning reading last_updated/.map { |i| [t("wk.#{i}"), i] }
    options_for_select(opts, selected)
  end

  def wk_kanji_image_menu(selected)
    opts = [[t("all"), ""], [t("wk.kanji.image"), "kayo"]]
    options_for_select(opts, selected)
  end

  def wk_vocab_order_menu(selected)
    opts = %w/level reading last_updated/.map { |i| [t("wk.#{i}"), i] }
    opts.insert 1, [t("wk.vocab.characters"), "characters"]
    opts.push [t("wk.vocab.last_noted"), "last_noted"]
    options_for_select(opts, selected)
  end

  def wk_vocab_parts_menu(selected)
    opts = t("wk.parts").map { |k, v| [v, k] }
    options_for_select(opts, selected)
  end

  def wk_verb_pair_category_menu(selected)
    opts = Wk::VerbPair::CATEGORIES.map { |c| [t("wk.verb_pair.categories.#{c}", locale: "jp"), c] }
    opts.unshift [t("any", locale: "jp"), ""]
    options_for_select(opts, selected)
  end

  def wk_verb_pair_order_menu(selected)
    opts = [
      ["#{t('wk.verb_pair.transitive_suffix')}/#{t('wk.verb_pair.category')}",   "tsuffix_group"],
      ["#{t('wk.verb_pair.intransitive_suffix')}/#{t('wk.verb_pair.category')}", "isuffix_group"],
      ["#{t('wk.verb_pair.category')}/#{t('wk.verb_pair.transitive_suffix')}",   "group_tsuffix"],
      ["#{t('wk.verb_pair.category')}/#{t('wk.verb_pair.intransitive_suffix')}", "group_isuffix"],
      [t('wk.verb_pair.transitive_reading'),                                          "treading"],
      [t('wk.verb_pair.intransitive_reading'),                                        "ireading"],
    ]
    %w/category transitive_suffix intransitive_suffix/.map { |i| [t("wk.verb_pair.#{i}"), i] }
    options_for_select(opts, selected)
  end

  def wk_group_category_menu(selected, search: false, new_record: false)
    opts = Wk::Group::CATEGORIES.map { |c| [t("wk.group.categories.#{c}"), c] }
    opts.unshift [t("any"), ""] if search
    opts.unshift [t("select"), ""] if new_record
    options_for_select(opts, selected)
  end

  def wk_hidden_menu(selected)
    opts = %w/all hidden visible/.map { |o| [t(o), o] }
    options_for_select(opts, selected)
  end
end
