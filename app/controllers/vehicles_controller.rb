class VehiclesController < ApplicationController
  authorize_resource
  before_action :find_vehicle, only: [:show, :edit, :update, :destroy]

  def index
    @vehicles = Vehicle.search(params, vehicles_path, remote: true)
  end

  def new
    @vehicle = Vehicle.new
  end

  def create
    @vehicle = Vehicle.new(strong_params)
    if @vehicle.save
      redirect_to @vehicle
    else
      render action: "new"
    end
  end

  def update
    if @vehicle.update(strong_params)
      redirect_to @vehicle
    else
      render action: "edit"
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to vehicles_path
  end

  private

  def find_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def strong_params
    params.require(:vehicle).permit(:description, :registration, :resident_id)
  end
end
