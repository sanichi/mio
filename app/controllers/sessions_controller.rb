class SessionsController < ApplicationController
  def create
    user = authenticate_user(params[:email])
    if user
      if user.otp_required?
        session[:otp_user_id] = user.id
        redirect_to new_otp_secret_path
        success = nil
      else
        session[:user_id] = user.id
        redirect_to last_path
        success = true
      end
    else
      flash.now[:alert] = I18n.t("login.invalid").sample
      render :new, status: :unprocessable_content
      success = false
    end
    Login.create(email: params[:email], success: success, ip: request.remote_ip) unless success.nil?
  end

  def destroy
    session.delete(:user_id)
    redirect_to last_path
  end

  private

  def last_path
    session[:last_path] || root_path
  end

  def authenticate_user(email)
    user = User.find_by(email: email)
    return user if current_user.admin? # admin can impersonate any user
    user&.authenticate(params[:password])
  end
end
