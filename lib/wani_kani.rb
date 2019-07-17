require 'net/https'
require 'uri'
require 'open-uri'
require 'mechanize'

class WaniKani
  DELAY = 3.0

  attr_reader :api, :username, :password, :vocab, :kanji, :radical

  def initialize(credentials)
    raise "invalid WaniKani credentials" unless credentials.is_a?(Hash)
    @api, @username, @password = %i/api username password/.map { |k| credentials[k] }
    raise "invalid WaniKani API key" unless @api.is_a?(String) && @api.length == 32
    raise "invalid WaniKani username" unless @username.is_a?(String) && @username.present?
    raise "invalid WaniKani password" unless @password.is_a?(String) && @password.present?
  end

  def vocabs
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

  def kanjis
    uri = URI.parse("https://www.wanikani.com/api/user/#{api}/kanji")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    data = ActiveSupport::JSON.decode(response.body)
    raise "kanji data not a hash" unless data&.is_a?(Hash)
    data = data["requested_information"]
    raise "kanji data has no 'requested_information' array" unless data&.is_a?(Array)
    raise "array does not consist entirely of hashes with 'character' entries" unless data.all?{ |v| v.is_a?(Hash) && v.has_key?("character") }
    @kanji = data.each_with_object({}) { |v, h| h[v["character"]] = v }
    @kanji.keys
  end

  def radicals
    uri = URI.parse("https://www.wanikani.com/api/user/#{api}/radicals")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    data = ActiveSupport::JSON.decode(response.body)
    raise "radical data not a hash" unless data&.is_a?(Hash)
    data = data["requested_information"]
    raise "radical data has no 'requested_information' array" unless data&.is_a?(Array)
    raise "array does not consist entirely of hashes with 'character' entries" unless data.all?{ |v| v.is_a?(Hash) && v.has_key?("character") }
    @radical = data.each_with_object({}) { |v, h| h[v["character"]] = v unless v["character"].nil? }
    @radical.keys
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

  def scrape(kanji)
    sleep(DELAY)
    page = agent.get("/vocabulary/#{kanji}")

    src = page.search("//audio/source").map { |s| s["src"]&.sub(/\A.*\//, "") }
    raise "no audio sources found for '#{kanji}'" unless src.any?
    mp3 = src.select { |s| s =~ /\.mp3/ }
    audio_link = mp3.any?? mp3.first : src.first
    audio_link = remove_args(audio_link)
    audio_file = sanitize(audio_link)

    src = page.search("//section[@id='information']/div[contains(@class,'part-of-speech')]/p").map{ |s| s.text }
    raise "no part-of-speech found for '#{kanji}'" unless src.any?
    category = src.first.downcase

    download_audio(audio_link, audio_file)

    [audio_file, category]
  end

  def permission_granted?(count=1)
    return true if @permission_granted
    print "  update [Ynqc]? "
    case gets.chomp
    when /\Ac(ontinue)?\z/i
      @permission_granted = true
    when "", /\Ay(es)?\z/i
      true
    when /\Ano?\z/i
      false
    when /\A(q(uit)?|e?x(it)?)\z/i
      puts "user chose to exit"
      exit
    else
      if count < 3
        permission_granted?(count + 1)
      else
        raise("too many invalid responses")
      end
    end
  end

  private

  def download_audio(source, file)
    sleep(DELAY)
    source = audio_source(source)
    target = audio_target(file)
    File.open(target, "wb") do |t|
      open(source, "rb") do |s|
        t.write(s.read)
      end
    end
  end

  def audio_dir
    return @audio_dir if @audio_dir
    base = Rails.env == "production" ? "/var/www/mio/current" : "/Users/mjo/Projects/sni_mio_app"
    @audio_dir = "#{base}/public/system/audio/wani_kani"
    raise "#{@audio_dir} does not exist" unless Dir.exist?(@audio_dir)
    @audio_dir
  end

  def audio_source(link)
    "https://cdn.wanikani.com/audios/#{link}"
  end

  def audio_target(file)
    "#{audio_dir}/#{file}"
  end

  def sanitize(link)
    link.gsub("%", "_")
  end

  def remove_args(link)
    link.sub(/\?.*\z/, "")
  end
end
