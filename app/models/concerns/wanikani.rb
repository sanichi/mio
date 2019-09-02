module Wanikani
  extend ActiveSupport::Concern

  module ClassMethods
    def get_data(type)
      sleep 0.1

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

      data
    end
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
      puts "exiting"
      exit
    else
      if count < 3
        permission_granted?(count + 1)
      else
        puts "too many invalid user responses"
        exit
      end
    end
  end
end
