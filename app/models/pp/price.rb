module Pp
  class Price < ApplicationRecord
    include Pageable

    self.table_name = 'pp_prices'

    belongs_to :station

    validates :price_pence, presence: true, numericality: { greater_than: 0, less_than: 10000 }
    validates :price_last_updated, presence: true

    def self.search(params, path, opt = {})
      matches = includes(:station)
      case params[:order]
      when "price_down"
        matches = matches.order(price_pence: :desc)
      when "price_up"
        matches = matches.order(price_pence: :asc)
      when "update_down"
        matches = matches.order(price_last_updated: :desc)
      when "update_up"
        matches = matches.order(price_last_updated: :asc)
      when "station"
        matches = matches.order(station: {preferred_name: :asc}, price_last_updated: :desc)
      else
        matches = matches.order(price_last_updated: :desc)
      end
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
