module SoundHelper
  def sound_order_menu(selected)
    opts = %w/level ordinal name/.map { |o| [t("sound.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def sound_category_menu(selected)
    opts = Sound::CATEGORIES.map { |c| [t("sound.categories.#{c}"), c] }
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end

  def sound_level_menu(selected)
    count = Sound.pluck(:level).each_with_object(Hash.new(0)) { |l,h| h[l] += 1 }
    opts = Sound::LEVELS.map { |l| ["#{l} (#{count[l]})", l] }
    opts.unshift [t("all"), 0]
    options_for_select(opts, selected)
  end
end
