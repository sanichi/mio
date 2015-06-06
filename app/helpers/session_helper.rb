module SessionHelper
  private

  def current_user
    @current_user ||= User.new(role: session[:authenticated] ? "admin" : "none")
  end
end
