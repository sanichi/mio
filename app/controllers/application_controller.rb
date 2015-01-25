class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception # prevent CSRF attacks by raising an exception

  before_action :require_sign_in

  helper_method :authenticated?

  def authenticated?
    session[:authenticated]
  end

  def require_sign_in
    unless authenticated? || controller_name == "sessions"
      redirect_to sign_in_path
    end
  end
end
