module ConstellationHelper
  def constellation_search_order_menu(selected)
    opts = %w/name iau/.map { |o| [t("constellation.#{o}"), o] }
    opts.push [t("star.stars"), "stars"]
    options_for_select(opts, selected)
  end

  def constellation_wikipedia(wikipedia)
    "https://en.wikipedia.org/wiki/#{wikipedia}"
  end
end
