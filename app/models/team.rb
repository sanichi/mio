class Team < ApplicationRecord
  include Constrainable
  include Pageable

  [:won, :diff, :drawn, :lost, :played, :points, :for, :against].each do |a|
    attribute a, :integer, default: 0
  end
  attribute :latest_results
  attribute :upcoming_fixtures

  MAX_NAME = 30
  MAX_SHORT = 15
  MAX_DIVISION = 4
  MIN_DIVISION = 1

  has_many :home_matches, class_name: "Match", dependent: :destroy, foreign_key: "home_team_id"
  has_many :away_matches, class_name: "Match", dependent: :destroy, foreign_key: "away_team_id"

  before_validation :normalize_attributes

  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :short, presence: true, length: { maximum: MAX_SHORT }, uniqueness: true
  validates :slug, presence: true, length: { maximum: MAX_NAME }, uniqueness: true, format: { with: /\A[a-z]+(-[a-z]+)*\z/ }
  validates :division, numericality: { integer_only: true, more_than_or_equal_to: MIN_DIVISION, less_than_or_equal_to: MAX_DIVISION }

  scope :by_name,    -> { order(:name) }
  scope :by_short,   -> { order(:short) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches = by_name
    if sql = cross_constraint(params[:q], %w{name})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def monthResults(month="")
    uri = get_uri(month)
    sleep(0.2) # potentially this method run many times sequentially so be nice
    begin
      # get the response
      response = Net::HTTP.get_response(uri)
      body = response.body

      # pick out the line containing the data
      if body =~ /<script>Morph\.toInit\.payloads\.push\(function\(\) \{ Morph\.setPayload\('\/data\/bbc-morph-football-scores-match-list-data([^<]+)/
        script = $1
      else
        raise "can't find script"
      end

      # try to extract the JSON from this
      if script =~ /(\{"meta":\{.*\}\]\}\]\}\}\]\}\})/
        json = $1
      else
        if body =~ /No fixtures found for this date/
          return []
        else
          raise "can't get JSON"
        end
      end

      # parse and return the JSON
      data = JSON.parse(json, symbolize_names: true)

      # get the array of tournaments
      case data
      in body: { matchData: Array => tournaments }
      else
        raise "can't get tournaments"
      end

      # extract events from the premier league tournamants
      events = tournaments.map do |tournament|
        case tournament
        in tournamentDatesWithEvents: Hash => dates, tournamentMeta: { tournamentSlug: "premier-league" }
          dates.values.flatten
        else
          nil
        end
      end.compact.reduce([], :concat)
      raise "can't get events" unless events.size > 0

      # turn these events into hashes of just the data we want (team names and scores)
      events.map do |event|
        case event
        in
          {
            events: [
              {
                startTime: String => time,
                homeTeam: {
                  name: { full: String => home_team },
                  scores: { fullTime: home_score },
                },
                awayTeam: {
                  name: { full: String => away_team },
                  scores: { fullTime: away_score },
                },
              }
            ]
          }
          {
            date: Date.parse(time[0,10]),
            home_team: home_team,
            away_team: away_team,
            home_score: home_score,
            away_score: away_score,
          }
        else
          raise "can't match event"
        end
      end
    rescue => e
      e.message
    end
  end

  def checkResults(month="")
    uri = get_uri(month)
    begin
      # get the response
      response = Net::HTTP.get_response(uri)
      body = response.body

      # how many characters and lines
      puts "got #{body.length} characters"
      puts "got #{body.split("\n").length} lines"

      # how many scripts
      scripts = body.scan(/<script[^>]*>(.*?)<\/script>/).map(&:first)
      puts "got #{scripts.length} scripts"

      # elimnate any that don't have anything to do with our team
      scripts.filter! do |s|
        [name, "home", "away", "score"].map{ |w| s.include?(w) }.all?
      end
      puts "got #{scripts.length} potentially relevant script#{scripts.length == 1 ? '' : 's'}"

      # loop through each relevant script
      scripts.each do |s|
        # attemt to extract the JSON
        m = s.match(/\A(.*?)(\{\s*".*[\]}]{4}\})/)
        if m
          start, json = m.captures
          puts "start: #{start}"
          data = begin
            JSON.parse(json)
          rescue => p
            p.message
          end
          if data.is_a?(String)
            puts "couldn't parse JSON (#{data})"
          else
            puts "parsed JSON"
            puts JSON.generate(data, { array_nl: "\n", object_nl: "\n", indent: '  ', space_before: ' ', space: ' '})
          end
        else
          puts "can't find JSON in ..."
          puts s
        end
      end
    rescue => e
      e.message
    end
  end

  def seasonResults
    year = Match.current_season
    first = (8..12).map{ |m| [year, m] }
    second = (1..6).map{ |m| [year + 1, m] }
    months = (first + second).map { |ym| "%s-%02d" % ym }
    months.map{ |m| monthResults(m) }.flatten
  end

  def max(season)
    home_tot = home_matches.where(season: season).count
    away_tot = away_matches.where(season: season).count
    home_due = home_matches.where(season: season).where(home_score: nil).where(away_score: nil).count
    away_due = away_matches.where(season: season).where(home_score: nil).where(away_score: nil).count
    home_dun = home_tot - home_due
    away_dun = away_tot - away_due
    [home_dun + away_dun, home_due + away_due]
  end

  def stats(season, dun, due)
    # stats from completed matches plus recent results
    if dun > 0
      home = home_matches.by_date.where(season: season).where.not(home_score: nil).where.not(away_score: nil)
      away = away_matches.by_date.where(season: season).where.not(home_score: nil).where.not(away_score: nil)
      home.each { |m| goals m.home_score, m.away_score }
      away.each { |m| goals m.away_score, m.home_score }
      self.latest_results = (home.take(dun) + away.take(dun)).sort_by{ |m| m.date }.reverse.take(dun).reverse
    else
      self.latest_results = []
    end

    # upcoming fixtures not yet played
    if due > 0
      home = home_matches.by_date.where(season: season).where(home_score: nil).where(away_score: nil)
      away = away_matches.by_date.where(season: season).where(home_score: nil).where(away_score: nil)
      self.upcoming_fixtures = (home.reverse.take(due) + away.reverse.take(due)).sort_by{ |m| m.date }.take(due)
    else
      self.upcoming_fixtures = []
    end

    self
  end

  private

  def normalize_attributes
    name&.squish!
    slug&.squish!
    short&.squish!
  end

  def goals(us, them)
    self.played += 1
    self.for += us
    self.against += them
    self.diff += us - them
    if us > them
      self.won += 1
      self.points += 3
    end
    if us == them
      self.drawn += 1
      self.points += 1
    end
    if us < them
      self.lost += 1
    end
  end

  def get_uri(month)
    unless month =~ /\A20\d\d-(0[1-9]|1[0-2])\z/
      today = Date.today
      month = '%d-%02d' % [today.year, today.month]
    end
    URI.parse "https://www.bbc.co.uk/sport/football/teams/#{slug}/scores-fixtures/#{month}"
  end
end
