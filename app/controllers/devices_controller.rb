class DevicesController < ApplicationController
  authorize_resource
  before_action :find_device, only: [:show, :edit, :update, :destroy]

  def index
    @devices = Device.search(params, devices_path)
  end

  def new
    @device = Device.new
  end

  def create
    @device = Device.new(strong_params)
    if @device.save
      redirect_to @device
    else
      render "new"
    end
  end

  def update
    if @device.update(strong_params)
      redirect_to @device
    else
      render action: "edit"
    end
  end

  def destroy
    @device.destroy
    redirect_to devices_path
  end

  private

  def find_device
    @device = Device.find(params[:id])
  end

  def strong_params
    params.require(:device).permit(:name, :notes)
  end
end
