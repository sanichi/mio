class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.order(:bay).all
    @pdata = ParkingData.new(params[:p])
  end
end
