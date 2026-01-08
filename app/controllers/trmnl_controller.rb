class TrmnlController < ApplicationController
  before_action :authenticate_token

  def beans
    render json: { starling: Bean.starling }
  end

  private

  def authenticate_token
    auth_header = request.headers["Authorization"]
    token = auth_header&.sub(/^Bearer /, "")

    unless token == Rails.application.credentials.trmnl[:token]
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
