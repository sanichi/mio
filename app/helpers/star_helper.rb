module StarHelper
  def star_search_order_menu(selected)
    opts = %w/name distance magnitude created/.map { |o| [t("star.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def star_constellation_menu(star)
    opts = Constellation.order(:name).pluck(:name, :id)
    opts.unshift [t("select"), ""] if star.new_record?
    options_for_select(opts, star.constellation)
  end

  def star_constellation_search_menu
    opts = Constellation.order(:name).pluck(:name, :id)
    opts.unshift [t("any"), ""]
    options_for_select(opts, params[:constellation_id])
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
end
