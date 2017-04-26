require 'net/https'
require 'uri'

class WaniKani
  attr_reader :key, :kanji

  def initialize(key)
    raise "invalid WaniKani key" unless key.present? && key.length == 32
    @key = key
  end

  def vocab
    uri = URI.parse("https://www.wanikani.com/api/user/#{key}/vocabulary")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    data = ActiveSupport::JSON.decode(response.body)
    raise "vocab data not a hash" unless data&.is_a?(Hash)
    data = data["requested_information"]
    raise "vocab data has no 'requested_information' hash" unless data&.is_a?(Hash) || data&.is_a?(Array)
    if data.is_a?(Hash)
      data = data["general"]
      raise "'requested_information' hash has no 'general' array" unless data&.is_a?(Array)
    end
    raise "array does not consist entirely of hashes with 'character' entries" unless data.all?{ |v| v.is_a?(Hash) && v.has_key?("character") }
    @kanji = data
    @kanji.collect { |v| v["character"] }
  end
end

begin
  # Give log messages a bit of context.
  puts Date.today

  # Get the current vocabs from the DB.
  db_kanji = Vocab.pluck(:kanji)
  puts "current count in #{Rails.env} DB: #{db_kanji.size}"

  # Get the current user vocabs from WaniKani.
  wk = WaniKani.new(Rails.application.secrets.wani_kani_api)
  wk_kanji = wk.vocab
  puts "current count of user vocabulary: #{wk_kanji.size}"
rescue => e
  # Something for the log file.
  puts "exception: #{e.message}"
end
