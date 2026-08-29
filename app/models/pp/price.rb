module Pp
  class Price < ApplicationRecord
    include Pageable

    self.table_name = 'pp_prices'

    DEFAULT_BEGIN = 2 # months ago
    BEGIN_MONTHS = [1, 2, 4, 8]

    belongs_to :station

    validates :price_pence, presence: true, numericality: { greater_than: 0, less_than: 10000 }
    validates :price_last_updated, presence: true

    def self.search(params, path, opt = {})
      matches = includes(:station)
      case params[:order]
      when "price_down"
        matches = matches.order(price_pence: :asc)
      when "price_up"
        matches = matches.order(price_pence: :desc)
      when "update_down"
        matches = matches.order(price_last_updated: :asc)
      when "update_up"
        matches = matches.order(price_last_updated: :desc)
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

    # The stations the graph draws a line for, in legend order.
    def self.graph_stations
      Pp::Station.where(id: select(:station_id)).by_display_name
    end

    # One point per station per day, as [station index, date, pence]. Where a
    # station has several prices on one day the last of them wins.
    def self.graph_points(stations)
      indexes = stations.each_with_index.to_h { |station, i| [station.id, i] }
      latest = {}
      order(:price_last_updated).pluck(:station_id, :price_last_updated, :price_pence).each do |station_id, at, pence|
        index = indexes[station_id]
        latest[[index, at.to_date]] = pence.to_f if index
      end
      latest.map { |(index, date), pence| [index, date, pence] }
    end

    def price_pounds
      (price_pence / 100.0).round(3)
    end

    def price_display
      format("%.1fp", price_pence)
    end

    def price_delta_display
      prev = station.prices.where('price_last_updated < ?', price_last_updated).order(price_last_updated: :desc).first
      return nil unless prev
      diff = price_pence - prev.price_pence
      sign = diff > 0 ? "+" : ""
      diff % 1 == 0 ? format("%s%d", sign, diff) : format("%s%.1f", sign, diff)
    end

    def last_updated_text
      days = (Date.current - price_last_updated.to_date).to_i
      case days
      when 0 then "today"
      when 1 then "yesterday"
      else "#{days} days ago"
      end
    end
  end
end
