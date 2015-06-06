module SessionHelper
  private

  def current_user
    return @current_user if @current_user
    user = User.find_by(id: session[:user_id]) if session[:user_id]
    @current_user = user || User.new(role: "none")
  end
end
