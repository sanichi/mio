class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.order(:bay).all
    @pdata = ParkingData.new.pdata if params[:p]
  end
end
