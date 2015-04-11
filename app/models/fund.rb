class Fund < ActiveRecord::Base
  include Pageable

  CATEGORIES = %w/it oeic ut/
  MIN_RRP = 1
  MAX_RRP = 7

  validates :annual_fee, numericality: { greater_than_or_equal_to: 0.0, less_than: 2.0 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :company, :name, presence: true, length: { maximum: 50 }
  validates :risk_reward_profile, numericality: { integer_only: true, greater_than_or_equal_to: MIN_RRP, less_than_or_equal_to: MAX_RRP }

  def self.search(params, path)
    matches = Fund.all
    matches = where(category: params[:category]) if CATEGORIES.include?(params[:category])
    matches = where("company LIKE '%#{params[:company]}") if params[:company].present?
    matches = where("name LIKE '%#{params[:name]}") if params[:name].present?
    paginate(matches, params, path)
  end
end
