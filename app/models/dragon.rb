class Dragon < ApplicationRecord
  include Constrainable
  include Pageable

  MIN_FIRST_NAME = 2
  MIN_LAST_NAME = 3
  MAX_FIRST_NAME = 15
  MAX_LAST_NAME = 20

  before_validation :canonicalize

  validates :first_name, presence: true, length: { maximum: MAX_FIRST_NAME, minimum: MIN_FIRST_NAME }, uniqueness: { scope: :last_name,
    message: I18n.t("dragon.duplicate") }
  validates :last_name, presence: true, length: { maximum: MAX_LAST_NAME, minimum: MIN_LAST_NAME }

  scope :by_last_name,  -> { order(:last_name, :first_name) }
  scope :by_first_name, -> { order(:first_name, :last_name) }

  def name(reversed = false)
    reversed ? "#{last_name}, #{first_name}" : "#{first_name} #{last_name}"
  end

  def self.search(params, path, opt={})
    sql = nil
    matches =
    case params[:order]
    when "first" then by_first_name
    else              by_last_name
    end
    matches = matches.where(sql) if sql = cross_constraint(params[:q], %w(last_name first_name))
    matches = matches.where(male: true) if params[:gender] == "male"
    matches = matches.where(male: false) if params[:gender] == "female"
    paginate(matches, params, path, opt)
  end

  private

  def canonicalize
    last_name&.squish!
    first_name&.squish!
  end
end
