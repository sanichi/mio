FOOTBALL_TEAMS = 20
FOOTBALL_MATCHES = FOOTBALL_TEAMS * (FOOTBALL_TEAMS - 1)

class FootballApi # abstract
  def teams
    data = get_data(base_url + teams_path)
    teams = get_teams(data)
    raise "bad teams (#{teams.class})" unless teams.is_a?(Array)
    raise "bad number of teams (#{teams.size})" unless teams.size == FOOTBALL_TEAMS
    teams
  end

  def matches
    data = get_data(base_url + matches_path)
    matches = get_matches(data)
    raise "bad matches (#{matches.class})" unless matches.is_a?(Array)
    raise "bad number of matches (#{matches.size})" unless matches.size == FOOTBALL_MATCHES
    matches
  end

  private

  def get_data(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    add_headers(request)
    r = http.request(request)
    if r.code != "200" || r.content_type != "application/json"
      raise "code: #{r.code}, content type: #{r.content_type}, message: #{r.message}"
    end
    json = r.read_body || "empty body"
    begin
      data = JSON.parse(json)
    rescue => e
      fb_report json, true
      raise "parse error: #{e.message}"
    end
    raise "bad data (#{data.class})" unless data.is_a?(Hash)
    data
  end
end

class FdFootballApi < FootballApi
  private

  def base_url = "https://api.football-data.org/v4/competitions/"
  def teams_path = "PL/teams"
  def matches_path = "PL/matches"
  def get_teams(data) = data["teams"]
  def get_matches(data) = data["matches"]
  def add_headers(request)
    request["X-AUTH-TOKEN"] = Rails.application.credentials.football_data[:token]
  end
end

class FwpFootballApi < FootballApi
  private

  def base_url = "https://api.footballwebpages.co.uk/v2/"
  def teams_path = "teams.json?comp=1"
  def matches_path = "fixtures-results.json?comp=1"
  def get_teams(data) = data["teams"]
  def get_matches(data) = data.dig("fixtures-results", "matches")
  def add_headers(request)
    request["FWP-API-Key"] = Rails.application.credentials.football_web_pages[:key]
  end
end

class FootballTeam # abstract
  def initialize(data, i)
    @data = data
    @i = i
    validate!
  end

  private

  def validate!
    raise "invalid team data (##{@i})" unless @data.is_a?(Hash)
    raise "invalid team ID (##{@i})" unless id.is_a?(Integer) && id >= 0
    raise "invalid team name (##{@i})" unless name.is_a?(String) && name.length > 0
  end
end

class FdFootballTeam < FootballTeam
  def id = @id ||= @data["id"]
  def name = @name ||= normalize_name

  private

  def short_name = @short_name ||= @data["shortName"]
  def normalize_name
    case short_name
    when "Tottenham" then "Spurs"
    when "Wolverhampton" then "Wolves"
    when "Nottingham" then "Forest"
    when "Brighton Hove" then "Brighton"
    else short_name
    end
  end
end

class FwpFootballTeam < FootballTeam
  def id = @id ||= @data["id"]
  def name = @name ||= @data["full-name"]
end

class FootballMatch # abstract
  def initialize(data, i)
    @data = data
    @i = i
    validate!
  end

  def score = "#{home_score || '?'}-#{away_score || '?'}"

  private

  def validate!
    raise "invalid team data (##{@i})" unless @data.is_a?(Hash)
    begin
      date
    rescue Date::Error
      raise "invalid match date (##{@i})"
    end
    raise "invalid home team ID (##{@i})" unless home_team_id.is_a?(Integer) && home_team_id >= 0
    raise "invalid away team ID (##{@i})" unless away_team_id.is_a?(Integer) && away_team_id >= 0
    raise "home and away teams are identical (##{@i})" if home_team_id == away_team_id
    unless home_score.nil? || (home_score.is_a?(Integer) && home_score >= 0)
      raise "invalid home score (##{@i})"
    end
    unless away_score.nil? || (away_score.is_a?(Integer) && away_score >= 0)
      raise "invalid away score (##{@i})"
    end
  end
end

class FdFootballMatch < FootballMatch
  def date = @date ||= Date.parse(@data["utcDate"].to_s)
  def home_team_id = @home_team_id ||= @data.dig("homeTeam", "id")
  def away_team_id = @away_team_id ||= @data.dig("awayTeam", "id")
  def home_score = @home_score ||= get_score("home")
  def away_score = @away_score ||= get_score("away")

  private

  def get_score(side) = @data.dig("score", "fullTime", side) || @data.dig("score", "halfTime", side)
end

class FwpFootballMatch < FootballMatch
  def date = @date ||= Date.parse(@data["date"].to_s)
  def home_team_id = @home_team_id ||= @data.dig("home-team", "id")
  def away_team_id = @away_team_id ||= @data.dig("away-team", "id")
  def home_score = @home_score ||= started? ? home_goals : nil
  def away_score = @away_score ||= started? ? away_goals : nil

  private

  def validate!
    super
    raise "invalid status (##{@i})" unless status.is_a?(String)
    raise "invalid home team score (##{@i})" unless home_goals.is_a?(Integer) && home_goals >= 0
    raise "invalid away team score (##{@i})" unless away_goals.is_a?(Integer) && away_goals >= 0
  end

  def status = @status ||= @data.dig("status", "short")
  def home_goals = @home_goals ||= @data.dig("home-team", "score")
  def away_goals = @away_goals ||= @data.dig("away-team", "score")
  def started?
    return @started if defined?(@started)
    # during match, status is minutes played (e.g. 05', 15', 45+6', 59', 90+11') or HT; after, it's FT
    started = status.match? /\A(FT|HT|\d\d?(\+\d\d?)?')\z/
    # if a goal has been scored then the game must have started
    started = home_goals > 0 || away_goals > 0 unless started
    @started = started
  end
end

def fb_report(str, error=false)
  str = JSON.generate(str, { array_nl: "\n", object_nl: "\n", indent: '  ', space_before: ' ', space: ' '}) unless str.is_a?(String)
  msg = "%s%s%s" % [@log ? "#{@api.to_s.upcase} " : "", error ? "ERROR " : "", str]
  if @log
    Rails.logger.info msg
  else
    puts msg
  end
end

def fb_set_api(str)
  case str
  when "fd"
    @api = :fd
    fb_report "using football-data"
  when "fwp"
    @api = :fwp
    fb_report "using football-web-pages"
  when nil
    @api = :fwp
    fb_report "defaulting to football-web-pages"
  else
    @api = :bad
    fb_report "invalid API (#{str})", true
    exit
  end
end

def fb_db_team(id, id_attr, cache, i)
  return cache[id] if cache[id]
  team = Team.find_by(id_attr => id)
  raise "team ID #{id} has no match with #{id_attr} in DB (##{i})" unless team
  cache[id] = team
  team
end

def fb_id_attr        = @api == :fd ? :fd_id                       : :fwp_id
def fb_api            = @api == :fd ? FdFootballApi.new            : FwpFootballApi.new
def fb_team(data, i)  = @api == :fd ? FdFootballTeam.new(data, i)  : FwpFootballTeam.new(data, i)
def fb_match(data, i) = @api == :fd ? FdFootballMatch.new(data, i) : FwpFootballMatch.new(data, i)

namespace :football do
  # Meant to be run by hand at the beginning of the season.
  # It will make sure all teams have an ID for the API selected.
  # No output (which is to the terminal) means all IDs are already present.
  # Examples:
  #   $ RAILS_ENV=production bin/rails football:teams        # chooses the default API (see fb_set_api)
  #   $ RAILS_ENV=production bin/rails football:teams\[fd\]  # uses football-data API
  #   $ RAILS_ENV=production bin/rails football:teams\[fwp\] # uses football-web-pages API
  desc "get API team IDs and check against our DB"
  task :teams, [:api] => :environment do |task, args|
    @log = false
    fb_set_api(args[:api]) # sets @api

    # get stuff we'll need below
    id_attr = fb_id_attr # the name of the DB team attribute holding the API ID

    begin
      fb_api.teams.each_with_index do |data, i|
        # get the API version of the team
        api_team = fb_team(data, i)

        # match this by name to a team in our database
        db_team = Team.find_by(name: api_team.name)
        db_team = Team.find_by(short: api_team.name) unless db_team
        raise "no such team as #{api_team.name} (##{i})" unless db_team

        # make sure the database has the correct API ID
        if db_team.send(id_attr) != api_team.id
          fb_report "setting API ID for #{db_team.name} (#{db_team.send(id_attr)} => #{api_team.id})"
          db_team.update_column(id_attr, api_team.id)
        end
      end
    rescue => e
      fb_report e.message, true
    end
  end

  # Mainly to be run from cron on a regular (e.g. every night) basis.
  # Creates or updates db matches from API data.
  # Examples:
  #   0 22 * * * cd /var/www/me.mio/current; RAILS_ENV=production bin/rails football:matches[fd,log] >> log/cron.log 2>&1
  #   $ RAILS_ENV=production bin/rails football:matches\[fwp\] # output to terminal
  desc "review and update all matches"
  task :matches, [:api, :log] => :environment do |task, args|
    @log = args[:log].is_a?(String) && args[:log].match?(/\Al(og)?\z/i)
    fb_set_api(args[:api]) # sets @api
    fb_report "started football:matches at #{Time.now}" if @log

    # get stuff we'll need below
    cache = {} # so do we don't have to keep looking up teams by their API ID
    season = Match.current_season # we're only concerned with the current season
    id_attr = fb_id_attr # the name of the DB team attribute holding the API ID

    begin
      fb_api.matches.each_with_index do |data, i|
        # get the API version of the team
        api_match = fb_match(data, i)

        # get the home and away DB teams
        home_team = fb_db_team(api_match.home_team_id, id_attr, cache, i)
        away_team = fb_db_team(api_match.away_team_id, id_attr, cache, i)

        # create or update the DB match object involving these two teams
        db_match = Match.find_by(home_team_id: home_team.id, away_team_id: away_team.id, season: season)
        if db_match
          updates = 0
          if db_match.date != api_match.date
            fb_report "updated #{home_team.short} - #{away_team.short} date (#{db_match.date.to_s} => #{api_match.date.to_s})"
            db_match.update_column(:date, api_match.date)
            updates += 1
          end
          if !api_match.home_score.nil? && !api_match.away_score.nil? && db_match.score != api_match.score
            fb_report "updated #{home_team.short} - #{away_team.short} score (#{db_match.score} => #{api_match.score})"
            db_match.update_column(:home_score, api_match.home_score) if db_match.home_score != api_match.home_score
            db_match.update_column(:away_score, api_match.away_score) if db_match.away_score != api_match.away_score
            updates += 1
          end
          db_match.touch if updates > 0
        else
          begin
            db_match = Match.create!(home_team_id: home_team.id, away_team_id: away_team.id, season: season, date: api_match.date, home_score: api_match.home_score, away_score: api_match.away_score)
            fb_report "created #{db_match.summary}"
          rescue => e
            raise "couldn't create match (##{i}): #{e.message}"
          end
        end
      end
    rescue => e
      fb_report e.message, true
    end

    fb_report "finished football:matches at #{Time.now}" if @log
  end

  # Meant to be run by hand anytime to check on the seemingly undocumented FWP status field.
  # Example:
  #   $ RAILS_ENV=production bin/rails football:fwp_status
  desc "List the current status values returned from the FWP API"
  task :fwp_status do |task|
    @log = false
    @api = :fwp
    stats = Hash.new(0)

    begin
      fb_api.matches.each do |data|
        stats[data.dig("status", "short") || "NULL"] += 1
      end
    rescue => e
      fb_report e.message, true
    end

    stats.sort_by { |_, value| -value }.each do |status, count|
      len = status.length
      dots = "." * (20 - len)
      fb_report "#{status} #{dots} #{count}"
    end
  end
end
