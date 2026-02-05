module Pp
  class Price < ApplicationRecord
    include Pageable

    self.table_name = 'pp_prices'

    belongs_to :station

    validates :price_pence, presence: true, numericality: { greater_than: 0, less_than: 10000 }
    validates :price_last_updated, presence: true

    scope :by_date, -> { order(price_last_updated: :desc) }

    def self.search(params, path, opt = {})
      matches = by_date.includes(:station)
      if params[:station_id].present?
        matches = matches.where(station_id: params[:station_id])
      end
      paginate(matches, params, path, opt)
    end

    def price_pounds
      (price_pence / 100.0).round(3)
    end

    def price_display
      format("%.1fp", price_pence)
    end
  end
end
