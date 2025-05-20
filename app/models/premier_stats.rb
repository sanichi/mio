class PremierStats
  MatchNumbers = [1, 7, 12, 18, 23, 29]

  attr_reader :season,   # first year of season, integer e.g. 2024
              :ids,      # ordered list of team IDs in the premier league in that season
              :name,     # hash from team ID to short name
              :played,   # hash from team ID to number of games played
              :won,      # hash from team ID to number of wins
              :drew,     # hash from team ID to number of draws
              :lost,     # hash from team ID to number of losses
              :points,   # hash from team ID to number of points
              :for,      # hash from team ID to goals for
              :against,  # hash from team ID to goals against
              :diff,     # hash from team ID to goal difference
              :labels,   # hash from team ID to array of match labels in date order
              :tooltips, # hash from team ID to array of match tooltips in date order
              :number,   # one of the numbers in MatchNumbers
              :numbers   # array of 10 consecutive match numbers (less 1 so they are indexes into labels and tooltips)

  def initialize(season, number)
    # Season.
    if Match.seasons.include?(season.to_i)
      @season = season.to_i
    else
      @season = Match.current_season
    end

    # Match numbers.
    if MatchNumbers.include?(number.to_i)
      @number = number.to_i
    else
      @number = 0 # we'll calculate the best one later when we have more info
    end

    # Get array of IDs and hash of names.
    @ids = []
    @name = {}
    Team.pluck(:id, :short).each do |id,short|
      @ids.push id
      @name[id] = short
    end

    # Get all the stats.
    present = {}
    @played = Hash.new(0)
    @won = Hash.new(0)
    @drew = Hash.new(0)
    @lost = Hash.new(0)
    @points = Hash.new(0)
    @for = Hash.new(0)
    @against = Hash.new(0)
    @diff = Hash.new(0)
    @labels = Hash.new { |h,k| h[k] = [] }
    @tooltips = Hash.new { |h,k| h[k] = [] }
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

    # Prune and sort the IDs.
    @ids.select!{ |id| present[id] }.sort!{ |a,b| [@points[b], @diff[b], @name[a]] <=> [@points[a], @diff[a], @name[b]] }

    # Do we need to calculate the best match number (first of the 10) to use?
    if @number == 0
      @number =
        case (@ids.map{|id| @played[id]}.sum.to_f / @ids.size).round
        when (0..6)
          MatchNumbers[0] # 1
        when (7..12)
          MatchNumbers[1] # 7
        when (13..19)
          MatchNumbers[2] # 12
        when (20..25)
          MatchNumbers[3] # 18
        when (26..32)
          MatchNumbers[4] # 23
        else
          MatchNumbers[5] # 29
        end
    end

    # Calculate the 10 match index numbers to use from the match number.
    @numbers = (@number-1..@number+8).to_a
  end
end
