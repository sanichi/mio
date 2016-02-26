class Parking < ActiveRecord::Base
  include Pageable

  belongs_to :vehicle, required: true
  belongs_to :bay, required: true

  scope :by_date,  -> { order(created_at: :desc) }

  validates :bay_id, :vehicle_id, numericality: { integer_only: true, greater_than: 0 }

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
    registration&.squish!.upcase
  end
end
