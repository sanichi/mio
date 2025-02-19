module SessionHelper
  private

  def current_user
    return @current_user if @current_user
    user = User.find_by(id: session[:user_id]) if session[:user_id]
    @current_user = user || User.guest
  end

  def current_realm
    session[:current_realm] || Person::MIN_REALM
  end
end
