class BaysController < ApplicationController
  authorize_resource
  before_action :find_bay, only: [:show, :edit, :update, :destroy]

  def index
    @bays = Bay.search(params, bays_path, remote: true)
  end

  def new
    @bay = Bay.new
  end

  def create
    @bay = Bay.new(strong_params)
    if @bay.save
      redirect_to @bay
    else
      render action: "new"
    end
  end

  def update
    if @bay.update(strong_params)
      redirect_to @bay
    else
      render action: "edit"
    end
  end

  def destroy
    @bay.destroy
    redirect_to bays_path
  end

  private

  def find_bay
    @bay = Bay.find(params[:id])
  end

  def strong_params
    params.require(:bay).permit(:number, :resident_id)
  end
end
