def rapid_report(str, error=false)
  msg = "%s%s%s" % [@print ? "" : "RAPID ", error ? "ERROR " : "", str]
  if @print
    puts msg
  else
    Rails.logger.info msg
  end
end

def rapid_response(path)
  host = Rails.application.credentials.rapidapi[:host]
  url = URI("https://#{host}/#{path}.json?comp=1")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-key"] = Rails.application.credentials.rapidapi[:key]
  request["x-rapidapi-host"] = host
  http.request(request)
end

namespace :rapid do
  # meant to be run by hand at the beginning of the season
  # with the user's help, it will make sure the right teams are in the premier league
  desc "check premier league teams"
  task :check => :environment do |task|
    @print = true

    r = rapid_response("teams")

    if r.code != "200" || r.content_type != "application/json"
      rapid_report("code: #{r.code}, content type: #{r.content_type}, message: #{r.message}", true)
    else
      rapid_report(r.read_body)
    end
  end
end
