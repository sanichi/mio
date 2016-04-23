class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.where.not(bay: nil).order(:bay).all
    extra = !!params[:p] || can?(:view, Parking)
    @pdata = ParkingData.new(extra)
    @stats = ParkingStats.new(extra)
  end

  def risle_stats
    @stats = ParkingStats.new(true, params)
  end
end
