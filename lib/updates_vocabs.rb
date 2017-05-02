require 'net/https'
require 'uri'
require 'mechanize'

# Helper class.
class WaniKani
  DELAY = 5.0

  attr_reader :api, :username, :password, :vocab

  def initialize(credentials)
    raise "invalid WaniKani credentials" unless credentials.is_a?(Hash)
    @api, @username, @password = %w/api username password/.map { |k| credentials[k] }
    raise "invalid WaniKani API key" unless @api.is_a?(String) && @api.length == 32
    raise "invalid WaniKani username" unless @username.is_a?(String) && @username.present?
    raise "invalid WaniKani password" unless @password.is_a?(String) && @password.present?
  end

  def kanji
    uri = URI.parse("https://www.wanikani.com/api/user/#{api}/vocabulary")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    data = ActiveSupport::JSON.decode(response.body)
    raise "vocab data not a hash" unless data&.is_a?(Hash)
    data = data["requested_information"]
    raise "vocab data has no 'requested_information' hash" unless data&.is_a?(Hash)
    data = data["general"]
    raise "'requested_information' hash has no 'general' array" unless data&.is_a?(Array)
    raise "array does not consist entirely of hashes with 'character' entries" unless data.all?{ |v| v.is_a?(Hash) && v.has_key?("character") }
    @vocab = data.each_with_object({}) { |v, h| h[v["character"]] = v }
    @vocab.keys
  end

  def agent
    return @agent if @agent
    @agent = Mechanize.new
    page = @agent.get("https://www.wanikani.com/login")
    form = page.form_with(action: "/login")
    raise "can't find login form" unless form
    form["user[login]"] = username
    form["user[password]"] = password
    page = form.submit
    raise "failed login" if page.form_with(action: "/login")
    @agent
  end

  def audio(kanji)
    sleep(DELAY)
    page = agent.get("/vocabulary/#{kanji}")
    src = page.search("//audio/source").map { |s| s["src"]&.sub(/\A.*\//, "") }
    raise "no audio sources found for '#{janji}'" unless src.any?
    mp3 = src.select { |s| s =~ /\.mp3\z/ }
    mp3.any?? mp3.first : src.first
  end
end

# Main program.
begin
  # Give log messages a bit of context.
  puts Date.today

  # Get the kanji of the current vocabs from the DB.
  db_kanji = Vocab.pluck(:kanji)
  puts "current count in #{Rails.env} DB: #{db_kanji.size}"

  # Get the kanji of the current user vocabs from WaniKani.
  wk = WaniKani.new(Rails.application.secrets.wani_kani)
  wk_kanji = wk.kanji
  puts "current count of user vocabulary: #{wk_kanji.size}"

  # Get a list of vocab we don't have yet.
  new_kanji = wk_kanji - db_kanji
  puts "new vocabulary to retreive: #{new_kanji.size}"
  exit(true) unless new_kanji.any?

  # Loop over the new kanji.
  new_kanji.each do |kanji|
    # Get the API data for this vocab.
    data = wk.vocab[kanji]

    # Scrape the audio data (which isn't returned by the API) from the website for this vocab.
    audio = wk.audio(kanji)

    # Store all the new data in the DB.
    Vocab.create!(audio: audio, kanji: kanji, kana: data["kana"], level: data["level"], meaning: data["meaning"])
  end

  # Feedback about number created.
  puts "new vocabs created: #{new_kanji.size} (from #{new_kanji.first} to #{new_kanji.last})"
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}"
end
