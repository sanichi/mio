class TrmnlController < ApplicationController
  before_action :authenticate_token

  def starling
    render json: { starling: { current: Starling.current, savings: Starling.savings } }
  end

  def petrol
    stations = Pp::Station.by_price.limit(3).select { |s| s.latest_price.present? }
    if stations.empty?
      render json: { error: "No stations with prices" }
    else
      render json: {
        stations: stations.map do |s|
          price = s.latest_price
          {
            name: s.display_name,
            price: price.price_display,
            postcode: s.postcode,
            latitude: s.latitude,
            longitude: s.longitude
          }
        end
      }
    end
  end

  def premier
    # Rendered by app/views/trmnl/premier.json.jbuilder
  end

  private

  def authenticate_token
    return unless Rails.env.production?
    token = request.headers["Authorization"] || params[:token]
    return if token == Rails.application.credentials.trmnl[:token]
    # return if request.headers["Authorization"] == Rails.application.credentials.trmnl[:token]
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
