class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.where.not(bay: nil).order(:bay).all
    if can?(:read, Parking)
      @pdata = ParkingData.new
      @pstat = ParkingStat.new
    end
  end

  def risle_stats
    @pstat = ParkingStat.new(params)
  end

  def check
    respond_to do |format|
      format.json { render json: ::Checker.check }
    end
  end
end
