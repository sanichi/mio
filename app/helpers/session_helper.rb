module SessionHelper
  private

  def current_user
    @current_user ||= User.new(session[:authenticated] ? :admin : :guest)
  end
end
