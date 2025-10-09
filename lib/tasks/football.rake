class FootballApi # abstract
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
      data = JSON.parse(r.read_body)
    rescue => e
      fb_report(json, true)
      raise "parse error: #{e.message}"
    end
    raise "bad data (#{data.class})" unless data.is_a?(Hash)
    data
  end

  def teams
    data = get_data(base_url + teams_path)
    teams = get_teams(data)
    raise "bad teams (#{teams.class})" unless teams.is_a?(Array)
    raise "bad number of teams (#{teams.size})" unless teams.size == 20
    teams
  end

  def matches
    data = get_data(base_url + matches_path)
    matches = get_matches(data)
    raise "bad matches (#{matches.class})" unless matches.is_a?(Array)
    raise "bad number of matches (#{matches.size})" unless matches.size == 380
  end
end

class FdApi < FootballApi
  def base_url = "https://api.football-data.org/v4/competitions/"
  def teams_path = "PL/teams"
  def matches_path = "PL/matches"
  def get_teams(data) = data.dig("teams")
  def get_matches(data) = data.dig("matches")

  def add_headers(request)
    request["X-AUTH-TOKEN"] = Rails.application.credentials.football_data[:token]
  end
end

class FwpApi < FootballApi
  def base_url = "https://api.footballwebpages.co.uk/v2/"
  def teams_path = "teams.json?comp=1"
  def matches_path = "fixtures-results.json?comp=1"
  def get_teams(data) = data.dig("teams")
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
    raise "invalid team id (##{@i})" unless id.is_a?(Integer) && id >= 0
    raise "invalid team name (##{@i})" unless name.is_a?(String) && name.length > 0
  end
end

class FdFbTeam < FootballTeam # TODO: rename this after fdata.rake is gone
  def id = @id || @data["id"]
  def name = @name || normalize_name

  private

  def short_name = @short_name || @data["shortName"]

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

class FwpFbTeam < FootballTeam # TODO: rename this after fdata.rake is gone
  def id = @id || @data["id"]
  def name = @name || @data["full-name"]
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

def fb_api(str)
  case str
  when "fd", "football-data"
    :fd
  when "fwp", "football-web-pages"
    :fwp
  when nil
    fb_report "defaulting to football-web-pages"
    :fwp
  else
    fb_report "invalid API (#{str})", true
    exit
  end
end

def fb_get
  case @api
  when :fd
    FdApi.new
  when :fwp
    FwpApi.new
  else
    raise "unknown API (#{@api})"
  end
end

def fb_team(data, i)
  case @api
  when :fd
    FdFbTeam.new(data, i)
  when :fwp
    FwpFbTeam.new(data, i)
  else
    raise "unknown API (#{@api})"
  end
end

# the team ID names used in the database
def fb_id
  case @api
  when :fd
    :fd_id
  when :fwp
    :fwp_id
  else
    raise "unknown API (#{@api})"
  end
end

namespace :football do
  # TODO: add a comment here
  desc "get API team IDs and check against our DB"
  task :teams, [:api] => :environment do |task, args|
    @log = false
    @api = fb_api(args[:api])
    begin
      fb_get.teams.each_with_index do |data, i|
        # get the API version of the team
        api_team = fb_team(data, i)

        # match this by name to a team in our database
        db_team = Team.find_by(name: api_team.name)
        db_team = Team.find_by(short: api_team.name) unless db_team
        raise "no such team as #{api_team.name} (##{i})" unless db_team

        # make sure the database has the correct API
        id = fb_id
        if db_team.send(id) != api_team.id
          puts "setting API id for #{db_team.name} (#{db_team.send(id)} => #{api_team.id})"
          db_team.update_column(id, api_team.id)
        end
      end
    rescue => e
      fb_report(e.message, true)
    end
  end

  # TODO: add a comment here
  desc "review and update all matches"
  task :matches, [:api, :log] => :environment do |task, args|
    @log = args[:log].is_a?(String) && args[:log].match?(/\Al(og)?\z/i)
    @api = fb_api(args[:api])
    begin
      matches = fb_get.matches
      fb_report(matches.size.to_s)
    rescue => e
      fb_report(e.message, true)
    end
  end
end
