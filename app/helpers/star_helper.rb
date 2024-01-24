module StarHelper
  def star_search_order_menu(selected)
    opts = %w/name distance created/.map { |o| [t("star.order.#{o}"), o] }
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
      "#{$1}#{$2}° #{$2}′ #{$3}″"
    else
      delta
    end
  end
end
