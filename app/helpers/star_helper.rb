module StarHelper
  def star_search_order_menu(selected)
    opts = %w/name bayer components distance luminosity magnitude mass radius temperature/.map { |o| [t("star.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def star_constellation_menu(star)
    opts = Constellation.order(:name).pluck(:name, :id)
    opts.unshift [t("select"), ""] if star.new_record?
    options_for_select(opts, star.constellation_id)
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

  def star_decimal(d)
    return "" if d.nil?
    if d >= 10000.0
      "%.1e" % d
    elsif d >= 9.99
      d.round.to_s
    elsif d >= 0.99
      "%.1f" % d
    else
      "%.2f" % d
    end
  end

  def star_integer(i)
    return "" if i.nil?
    if i >= 10000
      "%.1e" % i
    else
      i.to_s
    end
  end

  def star_constellation(star)
    return star.constellation&.name.to_s unless star.bayer.present?
    "#{star_bayer(star.bayer)} #{star.constellation&.iau}".html_safe
  end

  def star_bayer(bayer)
    return "" unless bayer&.match(Star::BAYER)
    "#{$1}#{$2 ? "<sup>#{$2}</sup>" : ""}".html_safe
  end

  def star_wikipedia(wikipedia)
    "https://en.wikipedia.org/wiki/#{wikipedia}"
  end
end
