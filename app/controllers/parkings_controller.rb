class ParkingsController < ApplicationController
  authorize_resource

  def index
    @parkings = Parking.search(params, parkings_path, remote: true)
  end

  def new
    @parking = Parking.new
  end

  def create
    @parking = Parking.new(strong_params)
    if @parking.save
      redirect_to parkings_path
    else
      render action: "new"
    end
  end

  def destroy
    Parking.find(params[:id]).destroy
    redirect_to parkings_path
  end

  private

  def strong_params
    params.require(:parking).permit(:vehicle_id, :bay_id)
  end
end
