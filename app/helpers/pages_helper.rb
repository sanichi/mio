module PagesHelper
  def pages_risle_flat_positions(left, rite, x1, y1, x2, y2, x3, y3, x4, y4)
    max = [left.size, rite.size].max             # largest number of flats in each group
    (0...max).each_with_object([]) do |i, flats|
      tw = (i + 0.5) / max       # weight towards top end
      bw = (max - i - 0.5) / max # weight towards bottom end

      ls = x1 * tw + x4 * bw # left building side
      rs = x2 * tw + x3 * bw # right building side

      fp = left[i] && rite[i] ? 0.2 : 0.5  # fractional position of flats from left or right edge

      lx = ls + fp * (rs - ls) # left flat horizontal position
      rx = rs - fp * (rs - ls) # right flat horizontal position

      ly = y1 + bw * (y4 - y1) # left flat vertical position
      ry = y2 + bw * (y3 - y2) # right flat vertical position

      flats.push [left[i], lx, ly] if left[i]
      flats.push [rite[i], rx, ry] if rite[i]
    end
  end

  def season_menu(selected)
    opts = Match.seasons.reverse.map do |y|
      [y.to_s + "/" + (y+1).to_s[-2,2], y]
    end
    options_for_select(opts, selected)
  end

  def premier_check_season(candidate)
    if Match.seasons.include?(candidate.to_i)
      candidate.to_i
    else
      Match.current_season
    end
  end

  def premier_dun_due(dun_due)
    if dun_due == "dun"
      dun = 10
      due = 0
    elsif dun_due == "due"
      dun = 0
      due = 10
    else
      dun = 5
      due = 5
    end
    [dun, due]
  end
end
