class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email], encrypted_password: Digest::MD5.hexdigest(params[:password]))
    if user
      if user.otp_required?
        session[:otp_user_id] = user.id
        redirect_to new_otp_secret_path
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
    Login.create(email: params[:email], success: success, ip: request.remote_ip)
  end

  def destroy
    session.delete(:user_id)
    redirect_to last_path
  end

  private

  def last_path
    session[:last_path] || root_path
  end
end
