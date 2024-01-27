class StarsController < ApplicationController
  authorize_resource
  before_action :find_star, only: [:show, :edit, :update, :destroy]

  def index
    @stars = Star.search(params, stars_path, per_page: 10)
  end

  def new
    @star = Star.new
  end

  def create
    @star = Star.new(strong_params)
    if @star.save
      redirect_to @star
    else
      failure @star
      render :new
    end
  end

  def update
    if @star.update(strong_params)
      redirect_to @star
    else
      failure @star
      render :edit
    end
  end

  def destroy
    @star.destroy
    redirect_to stars_path
  end

  private

  def find_star
    @star = Star.find(params[:id])
  end

  def strong_params
    params.require(:star).permit(:name, :distance, :note, :alpha, :delta, :magnitude, :mass, :bayer, :constellation_id)
  end
end
