class Checker
  def self.check
    ok, message = check_nyc2016
    { ok: ok, message: message }
  end

  def self.check_nyc2016
    message = "message not set"
    ok = false
    url = "http://nyc2016.fide.com/"
    text = "Tickets to the Match will go on sale through Ticketmaster soon."
    xpath = "//div[@class='f-Info-cardItem']/h3[@class='f-Info-subTitle' and contains(.,'#{text}')]"

    begin
      rsp = Net::HTTP.get_response(URI(url))

      raise "bad status code (#{rsp.code})" unless rsp.code == "200"
      raise "bad content type (#{rsp.content_type})" unless rsp.content_type == "text/html"

      count = Oga.parse_html(rsp.body).xpath(xpath).size

      message =
        case count
          when 0 then "There might be tickets"
          when 1 then "Still no tickets"
          else raise "something's wrong (count=#{count})"
        end

      ok = true
    rescue Exception => e
      message = e.message.truncate(100)
    end

    [ok, message]
  end
end
