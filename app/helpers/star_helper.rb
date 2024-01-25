module StarHelper
  def star_search_order_menu(selected)
    opts = %w/name distance magnitude created/.map { |o| [t("star.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def star_right_ascension(alpha)
    if alpha&.match(Star::ALPHA)
      "#{$1}<sup>h</sup> #{$2}<sup>m</sup> #{$3}<sup>s</sup>".html_safe
    else
      alpha
    end
  end

  def star_declination(delta)
    if delta&.match(Star::DELTA)
      "#{$1}#{$2}° #{$3}′ #{$4}″"
    else
      delta
    end
  end

  def star_constellation_list
    Star.pluck(:constellation).uniq.compact.sort
  end
end
