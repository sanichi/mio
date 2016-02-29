class Parking < ActiveRecord::Base
  include Pageable

  attr_accessor :noted_at_string

  belongs_to :vehicle, required: true
  belongs_to :bay, required: true

  scope :by_date,  -> { order(noted_at: :desc) }

  before_validation :canonicalize

  validates :bay_id, :vehicle_id, numericality: { integer_only: true, greater_than: 0 }
  validate :noted_at_constraint

  def self.search(params, path, opt={})
    matches = by_date
    matches = matches.includes(:vehicle).includes(:bay)
    if (vid = params[:vehicle].to_i) > 0
      matches = matches.where(vehicle_id: vid)
    end
    if (bid = params[:bay].to_i) > 0
      matches = matches.where(bay_id: bid)
    end
    paginate(matches, params, path, opt)
  end

  private

  def canonicalize
    self.noted_at_string = "now" if noted_at_string.blank?
    self.noted_at = Chronic.parse(noted_at_string)
  end

  def noted_at_constraint
    error = nil

    if noted_at.blank?
      error = "invalid"
    elsif noted_at > Time.now
      error = "in the future"
    elsif noted_at < Time.now.days_ago(2)
      error = "too far in the past"
    end

    errors.add(:noted_at_string, error) if error
  end
end
