class PremierStats
  DEDUCTIONS = {
    2023 => {
      "Everton" => 8,
      "Forest"  => 4,
    }
  }

  attr_reader :season,       # first year of season, integer e.g. 2024
              :ids,          # ordered list of team IDs (by current standings)
              :name,         # hash from team ID to short name
              :played,       # hash from team ID to number of games played
              :won,          # hash from team ID to number of wins
              :drew,         # hash from team ID to number of draws
              :lost,         # hash from team ID to number of losses
              :points,       # hash from team ID to number of points
              :for,          # hash from team ID to goals for
              :against,      # hash from team ID to goals against
              :diff,         # hash from team ID to goal difference
              :labels,       # hash from team ID to array of 38 match labels
              :tooltips,     # hash from team ID to array of 38 match tooltips
              :home_start,   # initial start index for visible columns (0-28)
              :season_complete # true if all 38 games played by all teams

  def initialize(season)
    # season
    if Match.seasons.include?(season.to_i)
      @season = season.to_i
    else
      @season = Match.latest_season
    end

    # get array of IDs and hashes of ID -> name and name -> ID
    @ids = []
    @name = {}
    eman = {}
    Team.pluck(:id, :short).each do |id, short|
      @ids.push id
      @name[id] = short
      eman[short] = id
    end

    # get all the stats
    present = {}
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

    # calculate average games played and home start position
    calculate_home_start

    # check if season is complete (all teams played 38 games)
    @season_complete = @ids.all? { |id| @played[id] == 38 }
  end

  private

  def calculate_home_start
    # Average games played across all teams
    total_played = @ids.map { |id| @played[id] }.sum
    avg = (total_played.to_f / [@ids.size, 1].max).round

    # Start showing 5 games before average, clamped to valid range
    start = avg - 5
    start = 0 if start < 0
    start = 28 if start > 28

    @home_start = start
  end
end
