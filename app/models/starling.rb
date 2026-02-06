class Starling
  def self.savings = fetch_balance(:savings)
  def self.current = fetch_balance(:current)

  private

  # To get account IDs: curl -H "Authorization: Bearer <ACCESS_TOKEN>" https://api.starlingbank.com/api/v2/accounts

  def self.fetch_balance(account_type)
    account_id = Rails.application.credentials.starling[account_type]
    api_token = Rails.application.credentials.starling[:token]
    url = "https://api.starlingbank.com/api/v2/accounts/#{account_id}/balance"

    response = HTTParty.get(url, headers: { "Authorization" => "Bearer #{api_token}", "User-Agent" => "Curl" })
    raise "empty response" if response.body.blank?

    parsed = JSON.parse(response.body)
    pennies = parsed.dig("totalClearedBalance", "minorUnits")
    raise "invalid balance: #{pennies.inspect}" unless pennies.is_a?(Integer)

    pennies.to_f / 100
  rescue => e
    Rails.logger.error("Starling API error: #{account_type} #{e.class} #{e.message}")
    0.0
  end
end
