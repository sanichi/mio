class ParkingsController < ApplicationController
  authorize_resource

  def index
    @parkings = Parking.search(params, parkings_path, remote: true)
    @extra = can?(:delete, Parking) && @parkings.matches.select(&:deletable?).any?
  end

  def new
    @parking = Parking.new(noted_at_string: "now")
    if (vid = params[:vehicle].to_i) > 0
      @parking.vehicle_id = vid
    end
    if (bid = params[:bay].to_i) > 0
      @parking.bay_id = bid
    end
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
    params.require(:parking).permit(:vehicle_id, :bay, :noted_at_string)
  end
end
