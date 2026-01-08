class Bean
  def self.starling
    account = Rails.application.credentials.starling[:account]
    token = Rails.application.credentials.starling[:token]
    url = "https://api.starlingbank.com/api/v2/accounts/#{account}/balance"

    response = HTTParty.get(url, headers: {
      "Authorization" => "Bearer #{token}",
      "User-Agent" => "Curl"
    })
    raise "Starling API returned empty response" if response.body.nil? || response.body.empty?

    parsed = JSON.parse(response.body)
    minor_units = parsed.dig("effectiveBalance", "minorUnits")

    unless minor_units.is_a?(Integer) || (minor_units.is_a?(String) && minor_units.match?(/^-?\d+$/))
      raise "Starling API returned invalid balance: #{minor_units.inspect}"
    end

    gbp = minor_units.to_f / 100
    format("£%.2f", gbp)
  rescue => e
    Rails.logger.error("Starling API error: #{e.class} - #{e.message}")
    "Error"
  end
end
