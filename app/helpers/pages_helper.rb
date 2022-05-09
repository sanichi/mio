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

  def premier_data(candidate_season, dun_due)
    # season
    if Match.seasons.include?(candidate_season.to_i)
      season = candidate_season.to_i
    else
      season = Match.current_season
    end

    # teams
    if season == Match.current_season
      teams = Team.where(division: 1).to_a
    else
      teams = Match.where(season: season).pluck(:home_team_id).uniq.map{ |id| Team.find(id) }.to_a
    end

    # work out the requested dun/due
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

    # work out the maximumn possible dun/due
    max_dun, max_due = teams.each_with_object([0, 0]) do |t, m|
      mn, me = t.max(season)
      m[0] = mn if mn > m[0]
      m[1] = me if me > m[1]
    end

    # adjust the requested dun/due to take account of the maximums
    if dun > max_dun && due > max_due
      dun = max_dun
      due = max_due
    elsif dun > max_dun
      dun = max_dun
      due = 10 - dun
    elsif due > max_due
      due = max_due
      dun = 10 - due
    end

    # if either maximum is zero, we will need to signal this to the view
    one_sided = max_dun == 0 || max_due == 0

    # if there are no more due or no more done, signal that
    more_dun = dun < max_dun
    more_due = due < max_due

    # attach completed (dun) and forthcoming (due) matches to each team and then rank them all
    teams.map!{ |t| t.stats(season, dun, due) }.sort! do |a,b|
      if b.points > a.points
        1
      elsif b.points < a.points
        -1
      else
        if b.diff > a.diff
          1
        elsif b.diff < a.diff
          -1
        else
          a.short <=> b.short
        end
      end
    end

    # return the stuff we just calculated
    OpenStruct.new(
      season:    season,
      teams:     teams,
      dun:       dun,
      due:       due,
      one_sided: one_sided,
      more_dun:  more_dun,
      more_due:  more_due,
    )
  end
end
