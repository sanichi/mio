class SessionsController < ApplicationController
  def create
    if Digest::MD5.hexdigest(params[:password]) == Rails.application.secrets.password
      session[:authenticated] = true
      redirect_to root_path
    else
      render "new"
    end
  end

  def destroy
    session.delete(:authenticated)
    render "new"
  end
end
