module Pp
  class Station < ApplicationRecord
    include Constrainable
    include Pageable

    self.table_name = 'pp_stations'

    # Bounding box for Leith area (Crewe Toll to Musselburgh)
    LATITUDE_MIN  = 55.94   # Southern boundary (just below Portobello)
    LATITUDE_MAX  = 55.99   # Northern boundary (just offshore)
    LONGITUDE_MIN = -3.25   # Western boundary (past Crewe Toll)
    LONGITUDE_MAX = -3.02   # Eastern boundary (past Musselburgh)

    FUEL_TYPE = "E10"

    has_many :prices, dependent: :destroy

    before_validation :canonicalize

    validates :node_id, presence: true, length: { is: 64 }, uniqueness: true
    validates :name, presence: true, length: { maximum: 75 }
    validates :brand, length: { maximum: 30 }, allow_nil: true
    validates :address, length: { maximum: 50 }, allow_nil: true
    validates :postcode, length: { maximum: 10 }, allow_nil: true
    validates :latitude, presence: true,
              numericality: { greater_than_or_equal_to: LATITUDE_MIN, less_than_or_equal_to: LATITUDE_MAX }
    validates :longitude, presence: true,
              numericality: { greater_than_or_equal_to: LONGITUDE_MIN, less_than_or_equal_to: LONGITUDE_MAX }
    validates :preferred_name, length: { maximum: 75 }, allow_nil: true

    scope :by_name, -> { order(:name) }
    scope :by_display_name, -> { order(Arel.sql('COALESCE(preferred_name, name)')) }
    scope :by_price, -> {
      order(Arel.sql('(SELECT price_pence FROM pp_prices WHERE pp_prices.station_id = pp_stations.id ORDER BY price_last_updated DESC LIMIT 1) ASC NULLS LAST'))
    }

    def self.search(params, path, opt = {})
      matches = case params[:order]
      when "name"
        by_display_name
      else
        by_price
      end
      if sql = cross_constraint(params[:q], %w[name preferred_name address brand postcode])
        matches = matches.where(sql)
      end
      paginate(matches, params, path, opt)
    end

    def display_name
      preferred_name || name
    end

    def latest_price
      prices.order(price_last_updated: :desc).first
    end

    def self.in_bounds?(latitude, longitude)
      latitude  >= LATITUDE_MIN  && latitude  <= LATITUDE_MAX &&
      longitude >= LONGITUDE_MIN && longitude <= LONGITUDE_MAX
    end

    private

    def canonicalize
      self.preferred_name = nil if preferred_name.blank?
    end
  end
end
