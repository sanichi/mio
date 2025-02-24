class OtpSecretsController < ApplicationController
  def new
    if user = get_user
      if user.otp_secret.nil?
        session[:otp_secret] = Rails.env.test? ? User::OTP_TEST_SECRET : ROTP::Base32.random
        totp = ROTP::TOTP.new(session[:otp_secret], issuer: User::OTP_ISSUER)
        @qr_code = qr_code(totp, user.email)
        @su_code = session[:otp_secret]
      end
    else
      redirect_to new_session
    end
  end

  def create
    if (user = get_user) && (otp_secret = (user.otp_secret || session[:otp_secret]))
      totp = ROTP::TOTP.new(otp_secret, issuer: User::OTP_ISSUER)
      last_otp_at = totp.verify(params[:otp_attempt].to_s.gsub(/\s+/, ""), drift_behind: 15)
      if last_otp_at
        user.update_column(:last_otp_at, last_otp_at)
        user.update_column(:otp_secret, otp_secret) if user.otp_secret.nil?
        session[:otp_user_id] = nil
        session[:otp_secret] = nil
        session[:user_id] = user.id
        redirect_to(session[:last_path] || root_path)
        success = true
      else
        flash.now[:alert] = t("otp.invalid")
        @qr_code = qr_code(totp, user.email) if user.otp_secret.nil?
        render :new, status: :unprocessable_entity
        success = false
      end
      Login.create(email: user.email, success: success, ip: request.remote_ip)
    else
      redirect_to new_session_path
    end
  end

  private

  def get_user
    return nil unless current_user.guest?
    user = User.find_by(id: session[:otp_user_id])
    return nil unless user && user.otp_required?
    user
  end

  def qr_code(totp, email)
    RQRCode::QRCode
      .new(totp.provisioning_uri(email))
      .as_png(resize_exactly_to: 256)
      .to_data_url
  end
end
