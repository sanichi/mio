class TrmnlController < ApplicationController
  before_action :authenticate_token

  def starling
    render json: { current: Starling.current, savings: Starling.savings }
  end

  private

  def authenticate_token
    return if request.headers["Authorization"] == Rails.application.credentials.trmnl[:token]
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
