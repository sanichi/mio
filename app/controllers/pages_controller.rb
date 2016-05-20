class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.where.not(bay: nil).order(:bay).all
    if params[:p] || can?(:view, Parking)
      @pdata = ParkingData.new
      @pstat = ParkingStat.new
    end
  end

  def risle_stats
    @pstat = ParkingStat.new(params)
  end
end
