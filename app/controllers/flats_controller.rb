class FlatsController < ApplicationController
  authorize_resource
  before_action :find_flat, only: [:show, :edit, :update, :destroy]

  def index
    @flats = Flat.search(params, flats_path, remote: true)
  end

  def new
    @flat = Flat.new
  end

  def create
    @flat = Flat.new(strong_params)
    logger.info "XXX #{@flat.inspect}"
    if @flat.save
      redirect_to @flat
    else
      render action: "new"
    end
  end

  def update
    if @flat.update(strong_params)
      redirect_to @flat
    else
      render action: "edit"
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
    params.require(:flat).permit(:bay, :block, :building, :category, :name, :number, :owner_id, :tenant_id)
  end
end
