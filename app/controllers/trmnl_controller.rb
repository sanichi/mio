class TrmnlController < ApplicationController
  before_action :authenticate_token

  def beans
    render json: { starling: Bean.starling }
  end

  private

  def authenticate_token
    return if request.headers["Authorization"] == Rails.application.credentials.trmnl[:token]
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
