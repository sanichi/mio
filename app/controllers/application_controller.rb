class ApplicationController < ActionController::Base
  include SessionHelper

  protect_from_forgery with: :exception # prevent CSRF attacks by raising an exception
  helper_method :authenticated?

  rescue_from CanCan::AccessDenied do |exception|
    logger.warn "Access denied for #{exception.action} #{exception.subject} from #{request.ip}"
    redirect_to sign_in_path
  end

  def authenticated?
    session[:user_id]
  end
  
  def prev_next(key, objects)
    return unless objects.any?
    session[key] = "_#{objects.map(&:id).join('_')}_"
  end
end
