class Login < ApplicationRecord
  include Pageable

  MAX_IP = 39

  before_update :truncate_params

  def self.search(params, path, opt={})
    matches = Login.order(created_at: :desc)
    matches = matches.where("to_char(created_at, 'YYYY-MM-DD HH24:MI') ILIKE ?", "%#{params[:date]}%") if params[:date].present?
    matches = matches.where("email ILIKE ?", "%#{params[:email]}%") if params[:email].present?
    matches = matches.where("ip ILIKE ?", "%#{params[:ip]}%") if params[:ip].present?
    paginate(matches, params, path, opt)
  end

  private

  def truncate_params
    self.email = email.truncate(User::MAX_EMAIL) if email.present? && email.length > User::MAX_EMAIL
    self.ip = ip.truncate(MAX_IP) if ip.present? && ip.length > MAX_IP
  end
end
