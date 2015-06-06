class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email], encrypted_password: Digest::MD5.hexdigest(params[:password]))
    if user
      session[:user_id] = user.id
      redirect_to root_path
      success = true
    else
      render "new"
      success = false
    end
    Login.create(email: params[:email], success: success, ip: request.remote_ip)
  end

  def destroy
    session.delete(:user_id)
    render "new"
  end
end
