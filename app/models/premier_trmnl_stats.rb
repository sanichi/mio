class PremierTrmnlStats
  DEDUCTIONS = PremierStats::DEDUCTIONS

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
              :labels,       # hash from team ID to array of 10 visible match labels
              :indicies      # array of 10 match day indices to display

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
    all_labels = Hash.new { |h, k| h[k] = [] }

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
        if gd > 0
          @won[hid] += 1
          @lost[aid] += 1
          @points[hid] += 3
          all_labels[hid].push("W")
          all_labels[aid].push("L")
        elsif gd < 0
          @lost[hid] += 1
          @won[aid] += 1
          @points[aid] += 3
          all_labels[hid].push("L")
          all_labels[aid].push("W")
        else
          @drew[hid] += 1
          @drew[aid] += 1
          @points[hid] += 1
          @points[aid] += 1
          all_labels[hid].push("D")
          all_labels[aid].push("D")
        end
      else
        all_labels[hid].push("H")
        all_labels[aid].push("A")
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

    # calculate the 10 visible columns
    calculate_visible_window(all_labels)
  end

  private

  def calculate_visible_window(all_labels)
    # Average games played across all teams
    total_played = @ids.map { |id| @played[id] }.sum
    avg = (total_played.to_f / [@ids.size, 1].max).round

    # Start showing 5 games before average, clamped to valid range
    start = avg - 5
    start = 0 if start < 0
    start = 28 if start > 28

    # The 10 visible column indices
    @indicies = (start..start + 9).to_a

    # Keep full labels array so view can index by match day number
    @labels = all_labels
  end
end
