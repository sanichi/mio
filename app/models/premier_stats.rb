class PremierStats
  DEDUCTIONS = {
    2023 => {
      "Everton" => 8,
      "Forest"  => 4,
    }
  }

  attr_reader :season,   # first year of season, integer e.g. 2024
              :date,     # the focus date used to calculate the table
              :dates,    # ordered list of key dates relative to the focus
              :ids,      # ordered list of team IDs
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
              :indicies  # array of 10 indicies into labels and tooltips

  def initialize(season, date)
    # season
    if Match.seasons.include?(season.to_i)
      @season = season.to_i
    else
      @season = Match.latest_season
    end

    # get focus date and key dates aound it
    get_dates(@season, date) # sets @date and @dates

    # get array of IDs and hashes of ID → name and name → ID
    @ids = []
    @name = {}
    eman = {}
    Team.pluck(:id, :short).each do |id,short|
      @ids.push id
      @name[id] = short
      eman[short] = id
    end

    # get all the stats
    present = {}
    played = Hash.new(0) # actually played or will have played by @date
    @played = Hash.new(0) # actually played by @date
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
      if m.date <= @date && m.home_score.present? && m.away_score.present?
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
        if m.date <= @date
          played[hid] += 1
          played[aid] += 1
        end
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
    @ids.select!{ |id| present[id] }.sort!{ |a,b| [@points[b], @diff[b], @name[a]] <=> [@points[a], @diff[a], @name[b]] }

    # average number of games actually played or will have been played upto @date (inclusive)
    average = (@ids.map{|id| played[id]}.sum.to_f / @ids.size).round

    # start and finish indicies of highlighted games 10 games
    start = average - 5
    finish = start + 9
    if start < 0
      finish -= start
      start = 0
    end
    if finish > 37
      start += 37 - finish
      finish = 37
    end

    # calculate the indicies
    @indicies = (start..finish).to_a
  end

  private

  def get_dates(season, date)
    # we need some kind of date to work with
    begin
      @date = Date.parse(date.to_s)
    rescue Date::Error
      @date = Date.today
    end

    # key dates in relation to the focus date
    @dates = []

    # what are all the match dates in the season
    dates = Match.where(season: @season).order(:date).pluck(:date).uniq

    # this shouldn't happen but just in case
    if dates.size <= 1
      @date = dates.pop unless dates.empty?
      @dates.push @date
      return
    end

    # check our focus date makes sense in context
    @date = dates.last if @date > dates.last
    @date = dates.first if @date < dates.first

    # prepare to work out nearby dates
    before = dates.select { |d| d <= @date }
    after = dates.select { |d| d > @date }

    # we want the focus date to be an actual match date and not in before (or after)
    if before.size > 0 && @date == before.last
      before.pop
    else
      if before.size >= after.size
        @date = before.pop
      else
        @date = after.shift
      end
    end

    # the focus date itself
    @dates.push @date

    # first and last
    @dates.push before.first unless before.empty?
    @dates.push after.last unless after.empty?

    # next and previous
    @dates.push after.first if after.size > 1
    @dates.push before.last if before.size > 1

    # intermediate between first & previous and next & last
    @dates.push after[after.size/2] if after.size > 2
    @dates.push before[before.size/2] if before.size > 2

    # date order
    @dates.sort!
  end
end
