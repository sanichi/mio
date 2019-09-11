module Wanikani
  extend ActiveSupport::Concern

  @@continue = false

  module ClassMethods
    def get_subjects(url)
      sleep 1.1 # max is 60 requests per second

      uri = URI.parse(url)
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
      raise "response didn't contain an integer total count (#{total_count})" unless total_count.is_a?(Integer) || total_count < 0
      return [{}, nil] if total_count == 0
      data = hash["data"]
      raise "response has no data array (#{data.class})" unless data.is_a?(Array) && data.size > 0
      pages = hash["pages"]
      raise "response has no pages hash (#{pages.class})" unless pages.is_a?(Hash)
      next_url = pages["next_url"]

      [data, next_url]
    end

    def check(value, error)
      raise error unless yield value
      return value
    end

    def start_url(type, days)
      params = { types: type, hidden: false }
      if days.is_a?(Integer)
        if days >= 0
          since = Date.today.days_ago(days)
        else
          since = "forever"
        end
      else
        klass = case type
        when "radical"    then Wk::Radical
        when "kanji"      then Wk::Kanji
        when "vocabulary" then Wk::Vocab
        else raise "invalid subject type (#{type})"
        end
        since = klass.maximum(:last_updated)
      end
      params[:updated_after] = "#{since.to_s}T00:00:00Z" if since.is_a?(Date)
      params = params.map{ |k, v| "#{k}=#{v}" }.join("&")
      ["https://api.wanikani.com/v2/subjects?#{params}", since]
    end
  end

  def show_change(changes, method, name: nil, width: 20, max: nil, no_change: nil)
    name = method.gsub("_", " ") unless name.present?
    print "  %s%s " % [name, "." * (width - name.length)]
    change = changes[method]
    if change
      before = change.first
      before = before.truncate(max/2) if max
      after = change.last
      after = after.truncate(max/2) if max
      puts "#{before} => #{after}"
    else
      value = no_change || public_send(method)
      value = value.truncate(max) if max
      puts value
    end
  end

  def permission_granted?(count=1)
    return true if @@continue
    print "  update [Ynqc]? "
    case gets.chomp
    when /\Ac(ontinue)?\z/i
      @@continue = true
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
