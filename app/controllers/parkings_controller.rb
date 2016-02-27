class ParkingsController < ApplicationController
  authorize_resource
  before_action :bays_for_buttons, except: [:destroy]

  def index
    @parkings = Parking.search(params, parkings_path, remote: true)
  end

  def new
    @parking = Parking.new
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
    params.require(:parking).permit(:vehicle_id, :bay_id)
  end

  def bays_for_buttons
    @bay = Bay.all.each_with_object({}) { |b, h| h[b.number] = b }
  end
end
