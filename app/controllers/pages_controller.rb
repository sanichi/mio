class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.where.not(bay: nil).order(:bay).all
    @pdata = ParkingData.new(params[:p])
  end
end
