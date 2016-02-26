class Bay < ActiveRecord::Base
  include Constrainable
  include Pageable

  MAX_NUM = 86
  MIN_NUM = 0

  belongs_to :resident
  has_many :parkings, dependent: :destroy

  validates :number, numericality: { integer_only: true, greater_than_or_equal_to: MIN_NUM, less_than_or_equal_to: MAX_NUM }, uniqueness: true
  validates :resident_id, numericality: { integer_only: true, greater_than: 0 }, allow_nil: true

  scope :by_number, -> { order(:number) }

  def name
    number == 0 ? I18n.t("bay.street") : number.to_s
  end

  def self.search(params, path, opt={})
    matches = by_number
    matches = matches.includes(:resident).joins("LEFT JOIN residents ON bays.resident_id = residents.id")
    if sql = numerical_constraint(params[:number], :number)
      matches = matches.where(sql)
    end
    if (q = params[:owner]).present?
      matches = matches.where("residents.first_names ILIKE ? OR residents.last_name ILIKE ?", "%#{q}%", "%#{q}%")
    end
    paginate(matches, params, path, opt)
  end
end
