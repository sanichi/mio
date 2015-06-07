class Person < ActiveRecord::Base
  include Pageable
  include Remarkable

  MAX_FN = 100
  MAX_LN = 50
  MIN_YR = 1600

  before_validation :tidy_text

  validates :born, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YR }
  validates :died, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YR }, allow_nil: true
  validates :first_names, presence: true, length: { maximum: MAX_FN }
  validates :last_name, presence: true, length: { maximum: MAX_LN }

  validate :years_must_not_be_stupid

  def name(first_first=false)
    first_first ? "#{first_names} #{last_name}" : "#{last_name}, #{first_names}"
  end

  def years
    born || died ? "#{born}-#{died}" : ""
  end

  def notes_html
    to_html(notes)
  end

  def self.search(params, path, opt={})
    ord = case params[:order]
          when "first" then [:first_names, :last_name, :born]
          when "born"  then [:born, :last_name, :first_names]
          else              [:last_name, :first_names, :born]
          end
    matches = order(*ord)
    matches = matches.where("last_name ILIKE ?", "%#{params[:last_name]}%") if params[:last_name].present?
    matches = matches.where("first_names ILIKE ?", "%#{params[:first_names]}%") if params[:first_names].present?
    matches = matches.where("('' || born) LIKE ?", "%#{params[:born]}%") if params[:born].present?
    matches = matches.where(gender: true) if params[:gender] == "male"
    matches = matches.where(gender: false) if params[:gender] == "female"
    paginate(matches, params, path, opt)
  end

  private

  def tidy_text
    last_name.squish!
    first_names.squish!
  end

  def years_must_not_be_stupid
    errors.add(:born, "can't be in the future") if born.present? && born > Date.today.year
    errors.add(:died, "can't be in the future") if died.present? && died > Date.today.year
    errors.add(:died, "can't have died before being born") if born.present? && died.present? && born > died
  end
end
