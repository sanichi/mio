class TrmnlController < ApplicationController
  before_action :authenticate_token

  def starling
    render json: { starling: { current: Starling.current, savings: Starling.savings } }
  end

  def premier
    # Rendered by app/views/trmnl/premier.json.jbuilder
  end

  private

  def authenticate_token
    return if request.headers["Authorization"] == Rails.application.credentials.trmnl[:token]
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
