class Starling
  def self.savings = fetch_balance(:savings)
  def self.current = fetch_balance(:current)

  private

  def self.fetch_balance(account_type)
    account_id = Rails.application.credentials.starling[account_type]
    api_token = Rails.application.credentials.starling[:token]
    url = "https://api.starlingbank.com/api/v2/accounts/#{account_id}/balance"

    response = HTTParty.get(url, headers: {
      "Authorization" => "Bearer #{api_token}",
      "User-Agent" => "Curl"
    })
    raise "Starling API returned empty response" if response.body.blank?

    parsed = JSON.parse(response.body)
    minor_units = parsed.dig("effectiveBalance", "minorUnits")

    unless minor_units.is_a?(Integer) || (minor_units.is_a?(String) && minor_units.match?(/^-?\d+$/))
      raise "Starling API returned invalid balance: #{minor_units.inspect}"
    end

    gbp = minor_units.to_f / 100
    format("£%.2f", gbp)
  rescue => e
    Rails.logger.error("Starling API error: #{account_type} #{e.class} #{e.message}")
    "Error"
  end
end
