class Team < ApplicationRecord
  include Constrainable
  include Pageable

  [:won, :diff, :drawn, :lost, :played, :points, :for, :against].each do |a|
    attribute a, :integer, default: 0
  end

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
    unless month =~ /\A20\d\d-(0[1-9]|1[0-2])\z/
      today = Date.today
      month = '%d-%02d' % [today.year, today.month]
    end
    url = "https://www.bbc.co.uk/sport/football/teams/#{slug}/scores-fixtures/#{month}"
    uri = URI.parse(url)
    sleep(0.2)
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
      data = JSON.parse(json)
      raise "json data is not a hash" unless data.is_a?(Hash)

      # this should have a body hash
      body = data['body']
      raise "can't find body" unless body.is_a?(Hash)

      # this should have matchData array
      matchData = body['matchData']
      raise "can't find matchData" unless matchData.is_a?(Array) && matchData.size > 0

      # this should be an array of hashes with tournamentDatesWithEvents entries
      datesWithEvents = matchData.map do |md|
        md.is_a?(Hash) ? md['tournamentDatesWithEvents'] : nil
      end.compact
      raise "can't get datesWithEvents" unless datesWithEvents.size == matchData.size

      # each array element is a hash keyed on one or more dates
      events = datesWithEvents.map do |td|
        td.keys.map do |date|
          item = td[date]

          # each hash value is an array of hashes
          if item.is_a?(Array) && item.size == 1 && item.first.is_a?(Hash)
            item = item.first
          else
            raise "date data is not a single element array of hashes"
          end

          # each hash has round and events keys and we want the value for the latter
          if item.is_a?(Hash) && item["events"].is_a?(Array) && item["events"].size == 1
            item = item["events"].first
          else
            raise "date data element does not have an 'events' array"
          end

          # we only want Premier League games
          if item["tournamentName"]["full"] == "Premier League"
            # extract what we want from this hash
            {
              date: Date.parse(item["startTime"][0,10]),
              home_team: item["homeTeam"]["name"]["full"],
              away_team: item["awayTeam"]["name"]["full"],
              home_score: item["homeTeam"]["scores"]["score"],
              away_score: item["awayTeam"]["scores"]["score"],
            }
          else
            nil
          end
        end
      end.flatten.compact

      events
    rescue => e
      e.message
    end
  end

  def seasonResults
    today = Date.today
    year = today.year - (today.month <= 8 ? 1 : 0)
    first = (9..12).map{ |m| [year, m] }
    second = (1..8).map{ |m| [year + 1, m] }
    months = (first + second).map { |ym| "%s-%02d" % ym }
    months.map{ |m| monthResults(m) }.flatten
  end

  def get_stats(season)
    home_matches.where(season: season).each do |m|
      us = m.home_score || next
      them = m.away_score || next
      goals us, them
    end
    away_matches.where(season: season).each do |m|
      us = m.away_score || next
      them = m.home_score || next
      goals us, them
    end
    self
  end

  def self.sort!(teams)
    teams.sort! do |a,b|
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
          b.name <=> a.name
        end
      end
    end
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
end
