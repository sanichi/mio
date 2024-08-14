def rapid_report(str, error=false)
  str = JSON.generate(str, { array_nl: "\n", object_nl: "\n", indent: '  ', space_before: ' ', space: ' '}) unless str.is_a?(String)
  msg = "%s%s%s" % [@print ? "" : "RAPID ", error ? "ERROR " : "", str]
  if @print
    puts msg
  else
    Rails.logger.info msg
  end
end

def rapid_response(path)
  # request the data and do some basic checks on the response
  host = Rails.application.credentials.rapidapi[:host]
  url = URI("https://#{host}/#{path}.json?comp=1")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-key"] = Rails.application.credentials.rapidapi[:key]
  request["x-rapidapi-host"] = host
  r = http.request(request)
  if r.code != "200" || r.content_type != "application/json"
    rapid_report("path: #{path}, code: #{r.code}, content type: #{r.content_type}, message: #{r.message}", true)
    return nil
  end

  # parse the response JSON
  json = r.read_body
  data = nil
  begin
    data = JSON.parse(r.read_body)
  rescue => p
    rapid_report("path: #{path}, parse error: #{p.message}, JSON...", true)
    rapid_report(json)
  end

  # return whatever we got (potentially nil)
  data
end

namespace :rapid do
  # meant to be run by hand at the beginning of the season
  # it will make sure the right teams are in the premier league
  # no output means everything is already OK
  desc "check premier league teams"
  task :check => :environment do |task|
    @print = true

    # get the data
    path = "teams"
    data = rapid_response(path)

    # check and process the structure
    twenty = []
    begin
      raise "bad response" unless data
      raise "data is not a hash with a 'teams' key" unless data.is_a?(Hash) && data.has_key?("teams")
      teams = data["teams"]
      raise "data is not an array with 20 items" unless teams.is_a?(Array) && teams.size == 20

      # make sure each of these 20 teams is in the premier league
      teams.each_with_index do |t, i|
        id = t["id"]; raise "team #{i} has invalid id" unless id && id.is_a?(Integer) && id >= 0
        name = t["full-name"]; raise "team #{i} has invalid name" unless name && name.is_a?(String) && name.length > 5
        team = Team.find_by(name: name)
        raise "no such team as #{name}" unless team
        twenty.push(name)
        if team.division != 1
          team.update_column(:division, 1)
          puts "promoted #{name} to premier league"
        end
      end

      # find and update teams that are no longer in the premier league
      premier = Team.where(division: 1).to_a
      if premier.size > 20
        premier.each do |team|
          unless twenty.include?(team.name)
            team.update_column(:division, 2)
            puts "relegated #{team.name} from premier league"
          end
        end
      end
    rescue => e
      rapid_report("#{path}: #{e.message}", true)
      rapid_report(data) if data
    end
  end
end
