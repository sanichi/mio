class FlatsController < ApplicationController
  authorize_resource
  before_action :find_flat, only: [:show, :edit, :update, :destroy]

  def index
    remember_last_search(flats_path)
    @flats = Flat.search(params, flats_path)
  end

  def new
    @flat = Flat.new
  end

  def create
    @flat = Flat.new(strong_params)
    if @flat.save
      redirect_to @flat
    else
      failure @flat
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @flat.update(strong_params)
      redirect_to @flat
    else
      failure @flat
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @flat.destroy
    redirect_to flats_path
  end

  private

  def find_flat
    @flat = Flat.find(params[:id])
  end

  def strong_params
    params.require(:flat).permit(:bay, :block, :building, :category, :landlord_id, :name, :notes, :number, :owner_id, :tenant_id)
  end
end
