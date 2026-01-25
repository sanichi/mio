class PremierStats2
  DEDUCTIONS = {
    2023 => {
      "Everton" => 8,
      "Forest"  => 4,
    }
  }

  attr_reader :season,      # first year of season, integer e.g. 2024
              :date,        # the currently selected date
              :date_index,  # index of current date in match_dates
              :match_dates, # ordered array of all match dates in season
              :ids,         # ordered list of team IDs (by current standings)
              :name,        # hash from team ID to short name
              :played,      # hash from team ID to number of games played
              :won,         # hash from team ID to number of wins
              :drew,        # hash from team ID to number of draws
              :lost,        # hash from team ID to number of losses
              :points,      # hash from team ID to number of points
              :for,         # hash from team ID to goals for
              :against,     # hash from team ID to goals against
              :diff,        # hash from team ID to goal difference
              :labels,      # hash from team ID to array of match labels in date order
              :tooltips,    # hash from team ID to array of match tooltips in date order
              :indicies     # array of 10 indicies into labels and tooltips

  def initialize(season, date)
    # season
    if Match.seasons.include?(season.to_i)
      @season = season.to_i
    else
      @season = Match.latest_season
    end

    # get all match dates for the season
    @match_dates = Match.where(season: @season).order(:date).pluck(:date).uniq

    # determine the selected date and its index
    set_date_and_index(date)

    # get array of IDs and hashes of ID → name and name → ID
    @ids = []
    @name = {}
    eman = {}
    Team.pluck(:id, :short).each do |id, short|
      @ids.push id
      @name[id] = short
      eman[short] = id
    end

    # get all the stats (always calculated for current state, not date-dependent)
    present = {}
    games_by_date = Hash.new(0) # track games played/scheduled per team up to selected date
    @played = Hash.new(0)
    @won = Hash.new(0)
    @drew = Hash.new(0)
    @lost = Hash.new(0)
    @points = Hash.new(0)
    @for = Hash.new(0)
    @against = Hash.new(0)
    @diff = Hash.new(0)
    @labels = Hash.new { |h, k| h[k] = [] }
    @tooltips = Hash.new { |h, k| h[k] = [] }

    Match.where(season: @season).order(:date).each do |m|
      hid = m.home_team_id
      aid = m.away_team_id
      present[hid] = true
      present[aid] = true

      # track games up to selected date for column centering
      if m.date <= @date
        games_by_date[hid] += 1
        games_by_date[aid] += 1
      end

      if m.home_score.present? && m.away_score.present?
        @played[hid] += 1
        @played[aid] += 1
        @for[hid] += m.home_score
        @for[aid] += m.away_score
        @against[hid] += m.away_score
        @against[aid] += m.home_score
        gd = m.home_score - m.away_score
        @diff[hid] += gd
        @diff[aid] -= gd
        @tooltips[hid].push("#{m.home_score}-#{m.away_score} H #{@name[aid]}")
        @tooltips[aid].push("#{m.away_score}-#{m.home_score} A #{@name[hid]}")
        if gd > 0
          @won[hid] += 1
          @lost[aid] += 1
          @points[hid] += 3
          @labels[hid].push("W")
          @labels[aid].push("L")
        elsif gd < 0
          @lost[hid] += 1
          @won[aid] += 1
          @points[aid] += 3
          @labels[hid].push("L")
          @labels[aid].push("W")
        else
          @drew[hid] += 1
          @drew[aid] += 1
          @points[hid] += 1
          @points[aid] += 1
          @labels[hid].push("D")
          @labels[aid].push("D")
        end
      else
        @labels[hid].push("H")
        @labels[aid].push("A")
        @tooltips[hid].push("#{@name[aid]} #{m.date.strftime('%-d %b')}")
        @tooltips[aid].push("#{@name[hid]} #{m.date.strftime('%-d %b')}")
      end
    end

    # store average games for indicies calculation
    @average_games = games_by_date.values.sum.to_f / [games_by_date.size, 1].max

    # account for deductions
    if DEDUCTIONS.has_key?(@season)
      DEDUCTIONS[@season].each_pair do |short, amount|
        if (id = eman[short]) && present[id]
          @points[id] -= amount
        end
      end
    end

    # prune and sort the IDs
    @ids.select! { |id| present[id] }.sort! { |a, b| [@points[b], @diff[b], @name[a]] <=> [@points[a], @diff[a], @name[b]] }

    # calculate the indicies for the 10 columns centred around the selected date
    calculate_indicies
  end

  # Navigation target dates (nil if disabled)
  def nav_first
    @date_index > 0 ? @match_dates.first : nil
  end

  def nav_back5
    # Move back ~5 rounds worth of dates
    step = (@match_dates.size / 38.0 * 5).round
    target = @date_index - step
    target >= 0 ? @match_dates[target] : nil
  end

  def nav_back1
    # Move back ~1 round worth of dates
    step = (@match_dates.size / 38.0).round
    step = 1 if step < 1
    target = @date_index - step
    target >= 0 ? @match_dates[target] : nil
  end

  def nav_today
    # Find most recent match date on or before today
    today = Date.today
    target = if @match_dates.last <= today
      # Historical season: go to last match
      @match_dates.last
    else
      # Current season: find most recent played date
      recent = @match_dates.select { |d| d <= today }.last
      recent || @match_dates.first
    end
    # Return nil if already on that date (to disable button)
    target == @date ? nil : target
  end

  def nav_forward1
    # Move forward ~1 round worth of dates
    step = (@match_dates.size / 38.0).round
    step = 1 if step < 1
    target = @date_index + step
    target < @match_dates.size ? @match_dates[target] : nil
  end

  def nav_forward5
    # Move forward ~5 rounds worth of dates
    step = (@match_dates.size / 38.0 * 5).round
    target = @date_index + step
    target < @match_dates.size ? @match_dates[target] : nil
  end

  def nav_last
    @date_index < @match_dates.size - 1 ? @match_dates.last : nil
  end

  private

  def set_date_and_index(date)
    return if @match_dates.empty?

    # Parse the date parameter
    begin
      requested = Date.parse(date.to_s)
    rescue Date::Error
      requested = Date.today
    end

    # Find the closest match date
    if requested <= @match_dates.first
      @date_index = 0
    elsif requested >= @match_dates.last
      @date_index = @match_dates.size - 1
    else
      # Find exact match or closest earlier date
      @date_index = @match_dates.rindex { |d| d <= requested } || 0
    end

    @date = @match_dates[@date_index]
  end

  def calculate_indicies
    # Map date_index directly to starting column
    # date_index ranges from 0 to match_dates.size-1
    # start ranges from 0 to 28 (showing columns 1-10 through 29-38)
    max_start = 28
    start = (@date_index.to_f / [@match_dates.size - 1, 1].max * max_start).round
    start = [[start, 0].max, max_start].min
    finish = start + 9

    @indicies = (start..finish).to_a
  end
end
