class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.where.not(bay: nil).order(:bay).all
    @pdata = ParkingData.new(params[:p])
    @stats = ParkingStats.new(params[:p])
  end

  def risle_stats
    @stats = ParkingStats.new(true, params)
  end
end
