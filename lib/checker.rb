require "http"
require "oga"

class Checker
  def self.check
    ok, message = check_nyc2016
    { ok: ok, message: message }
  end

  def self.check_nyc2016
    message = "ERROR: message not set"
    ok = true
    text = "Tickets to the Match will go on sale through Ticketmaster soon."
    xpath = "//div[@class='f-Info-cardItem']/h3[@class='f-Info-subTitle' and contains(.,'#{text}')]"

    begin
      rs = HTTP.timeout(write: 1, connect: 1, read: 1).get("http://nyc2016.fide.com/")

      raise "bad status code (#{r.code})" unless rs.code == 200
      raise "bad content type (#{rs.content_type.mime_type})" unless rs.content_type.mime_type == "text/html"
      raise "bad charset (#{rs.content_type.charset})" unless rs.content_type.charset.downcase == "utf-8"

      count = Oga.parse_html(rs.to_s).xpath(xpath).size

      message =
        case count
          when 0 then "There might be tickets"
          when 1 then "Still no tickets"
          else raise "something's wrong (count=#{count})"
        end
    rescue Exception => e
      message = "Error: #{e.message}"
      ok = false
    end

    [ok, message]
  end
end
