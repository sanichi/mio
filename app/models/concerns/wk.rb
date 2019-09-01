module Wk
  DELAY = 0.1
  MAX_LEVEL = 60

  def self.table_name_prefix
    "wk_"
  end

  def self.get(type: "radical")
    sleep DELAY
    uri = URI.parse("https://api.wanikani.com/v2/subjects?types=#{type}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Wanikani-Revision"] = "20170710"
    req["Authorization"] = "Bearer #{Rails.application.credentials.wani_kani[:api2]}"
    res = http.request(req)
    raise "response content has wrong type (#{res.content_type})" unless res.content_type == "application/json"
    hash = ActiveSupport::JSON.decode(res.body)
    raise "response is not a hash #{hash.class}" unless hash&.is_a?(Hash)
    error = hash["error"]
    raise "response indicates an error (#{error})" if error
    total_count = hash["total_count"]
    raise "response didn't contain a positive integer total count (#{total_count})" unless total_count.is_a?(Integer) && total_count > 0
    data = hash["data"]
    raise "response has no data array (#{data.class})" unless data.is_a?(Array) && data.size > 0
    max_mnemonic = 0
    data.each do |radical|
      raise "radical has wrong type #{radical["object"]}" unless radical["object"] == type
      raise "radical data is not a hash #{radical.class}" unless radical&.is_a?(Hash)
      wk_id = radical["id"]
      raise "radical doesn't have a positive integer ID (#{wk_id})" unless wk_id.is_a?(Integer) && wk_id > 0
      next if wk_id == 225 # old 225/亼/Roof duplicates 78/宀/Roof
      next if wk_id == 401 # old 401/務/Task duplicates 71/用/Task
      rdata = radical["data"]
      raise "radical #{wk_id} doesn't have a data hash (#{rdata.class})" unless rdata.is_a?(Hash)
      level = rdata["level"]
      raise "radical #{wk_id} doesn't have a valid level (#{level})" unless level.is_a?(Integer) && level > 0 && level <= MAX_LEVEL
      meanings = rdata["meanings"]
      raise "radical #{wk_id} (#{level}) doesn't have meanings array (#{meanings.class})" unless meanings.is_a?(Array) && meanings.size > 0
      meanings.keep_if { |meaning| meaning.is_a?(Hash) && meaning["primary"] == true }
      raise "radical #{wk_id} (#{level}) doesn't have any primary meanings (#{level})" unless meanings.is_a?(Array) && meanings.size > 0
      name = meanings[0]["meaning"]
      raise "radical #{wk_id} (#{level}) doesn't have a name (#{level})" unless name.present?
      character = rdata["characters"]
      character = nil unless character&.length == 1
      mnemonic = rdata["meaning_mnemonic"]
      raise "radical #{wk_id} (#{level}, #{name}) doesn't have a mnemonic (#{mnemonic})" unless mnemonic.present?

      Wk::Radical.create!(character: character, level: level, mnemonic: mnemonic, name: name, wk_id: wk_id)

      max_mnemonic = mnemonic.length if mnemonic.length > max_mnemonic
    end

    puts "hello #{total_count} #{data.size} #{max_mnemonic}"
  end
end
