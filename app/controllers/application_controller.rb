class ApplicationController < ActionController::Base
  include SessionHelper

  protect_from_forgery with: :exception # prevent CSRF attacks by raising an exception
  helper_method :authenticated?
  before_action :enable_miniprofiler
  before_action :remember_last_non_autenticated_path

  rescue_from CanCan::AccessDenied do |exception|
    logger.warn "Access denied for #{exception.action} #{exception.subject} from #{request.ip}"
    case request.format.symbol
    when :json
      render json: {}
    else
      redirect_to sign_in_path
    end
  end

  def authenticated?
    session[:user_id]
  end

  def prev_next(key, objects)
    return unless objects.any?
    session[key] = "_#{objects.map(&:id).join('_')}_"
  end

  private

  def enable_miniprofiler
    if Rails.env.production? && current_user.admin?
      Rack::MiniProfiler.authorize_request
    end
  end

  def remember_last_non_autenticated_path
    return if request.method != "GET" || request.format != "text/html" || request.xhr?
    return if !current_user.guest? || controller_name == "sessions"
    session[:last_path] = request.path
  end
end
