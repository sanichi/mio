class InterfacesController < ApplicationController
  authorize_resource
  before_action :find_interface, only: [:edit, :show, :update, :destroy]

  def index
    @interfaces = Interface.search(params, interfaces_path)
  end

  def new
    @interface = Interface.new
  end

  def create
    @interface = Interface.new(strong_params)
    if @interface.save
      redirect_to @interface
    else
      render "new"
    end
  end

  def update
    if @interface.update(strong_params)
      redirect_to @interface
    else
      render "edit"
    end
  end

  def destroy
    @interface.destroy
    redirect_to interfaces_path
  end

  private

  def find_interface
    @interface = Interface.find(params[:id])
  end

  def strong_params
    params.require(:interface).permit(:address, :device_id, :name)
  end
end
