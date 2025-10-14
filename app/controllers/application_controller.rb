class ApplicationController < ActionController::Base
  include SessionHelper

  helper_method :authenticated?
  before_action :remember_last_non_authenticated_path

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

  def failure(object)
    flash.now[:alert] = object.errors.full_messages.join(", ")
  end

  private

  def remember_last_non_authenticated_path
    return if request.method != "GET" || request.format != "text/html" || request.xhr?
    return if !current_user.guest? || controller_name == "sessions" || controller_name == "otp_secrets"
    session[:last_path] = request.path
  end

  def remember_last_search(path)
    fullpath = request.fullpath
    extra = "last_search=true"
    unless fullpath.include?(extra)
      fullpath += fullpath.include?("?") ? "&" : "?"
      fullpath += extra
    end
    session["last_#{path}_search"] = fullpath
  end

  def store_return_page(resource, return_page)
    return_page = nil if return_page.blank?
    session["#{resource}_return_page"] = return_page
  end

  def retrieve_return_page(resource)
    return_page = session["#{resource}_return_page"]
    session["#{resource}_return_page"] = nil
    return_page
  end
end
